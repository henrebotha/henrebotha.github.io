---
layout: post
title: A Ruby execution path gotcha
date: 2015-07-1 18:00:00
tags: [ruby]
---
The principle of least astonishment is a guiding philosphy in the design of computer systems. Any operation, the principle says (roughly), should always have the least surprising result. It makes sense: computer systems are extremely complex, and if a user - or a developer - can't rely on her instincts, how can we expect her to use the system *at all*?

So on that note, consider the following Python code.

```python
if False:
  foo = 5
print(foo)
```

What do you expect the result to be? A `NameError`, of course! The always-false `if` statement prevents the assignment to `foo` from ever occurring, and so when we attempt to reference `foo`, the interpreter complains that no such name exists.

What about Javascript?

```javascript
if(false) {
  foo = 5;
}
console.log(foo);
```

Wahey! `ReferenceError`!

...Now what would Ruby do, do you think?

```ruby
if false
  foo = 5
end
puts foo
```

Surprise, surprise: it returns `nil`, instead of a `NameError` as any person who's ever used an interpreted language might expect. Somehow, `foo` has come into existence (albeit valueless), *despite not existing in any execution path*.

This is not a minor issue, either: some time ago, we discovered it to be the cause of a bug that prevented an entire feature on our site from working.

So what on Earth is the rationale here? How is Ruby able to see the variable that exists inside a block that *never executes*?

There's a subtly complicated Ruby feature at work here.

## Name ambiguity

You are certainly aware that in Ruby, we can call zero-argument methods without parentheses, like so:

```ruby
def foo:
  puts "Hello, World!"
end
foo()
# => Hello, World!
foo
# => Hello, World!
```

This seems like a trivial convenience feature, but it's much more complicated than that, because it has implications for **parsing**.

When your code gets read into the Ruby interpreter, it has to distinguish method calls from variable names in order to interpret your code correctly and unambiguously. So when it sees a token like `foo`, it has to decide: is this a method call or a variable reference? When not given enough context (such as parentheses), it has to default to one option or the other - and there's a logical choice here.

<!-- Do the below paragraph as an "aside" box of some kind. It's not necessary for understanding the post. -->

A variable will always shadow ("override") a method. Meaning if you have a local variable `foo` and a method `foo()`, `foo` will be treated as a variable reference. There's a good reason for this behaviour: if `foo` is assumed to be a variable, you can still access the method called `foo` - just call it with empty parentheses. But if `foo` is assumed to be the method, you have no way of explicitly accessing the variable. Therefore, Ruby prefers to assume it's a variable.

## Scope evaluation

In order for the above to work, the interpreter needs to know which tokens are in scope at any given point. (This is because tokens - be they variable names or method names - must obey scoping rules. `ModuleOne#foo` is not necessarily the same thing as `ModuleOne::ModuleTwo#foo`.) **This means it has to run through all branches before starting execution**.

So, when Ruby parses our code, it runs through all branches, gets to a variable name `foo`, sees that we are assigning to it, realises it is therefore a variable name, and instantiates it with the value `nil`.

Here's why that's such a bastard.

```ruby
def foo:
  {bar: 'baz'}
end
foo = {} if foo.nil?
```

Let's rewrite it to make it a little clearer what's happening here.

```ruby
def foo:
  {bar: 'baz'}
end
if foo.nil?
  foo = {}
end
```

Even though line 5 will never execute - because the method `foo` will never return nil - the simple fact that `foo =` was ever written down will mean that `foo` is hereafter treated as a variable name. Attempting to call your method `foo` without parentheses explicitly appended will yield a `nil` value every time - and ironically, **this is the very behaviour we are attempting to prevent in lines 4 through 6**.

The takeaway here is this: if you ever use a token on the left-hand side of an assignment - *even an assignment that can't happen* - that token, on its own, references a variable, and that can cause headaches when you're trying to access a method, or expecting a variable to not exist.

## Bonus

For those who are interested, the line that broke our code looked like this:

```ruby
search_params = search_params.nil? ? {} : search_params
```

`search_params` is a method - the Rails 4 "strong params" kind. But because here we *assigned* to `search_params`, the last mention of it in the line became a variable reference, and so regardless of whether `search_params()` returned anything, after this line `search_params` would always equal `nil`.

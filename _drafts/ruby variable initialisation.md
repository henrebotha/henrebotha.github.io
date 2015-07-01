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

Surprise, surprise: it returns `nil`, instead of a `NameError` as any person who's ever used an interpreted language might expect. Somehow, `foo` has come into existence (albeit valueless), *despite not existing in the code's execution path*.

This is not a minor issue, either: recently, we discovered it to be the cause of a bug that prevented an entire feature on our site from working.

So what on Earth is the rationale here? How is Ruby able to see the variable that exists inside a block that *never executes*?

There are two Ruby features at work here.

## Name ambiguity

You are certainly aware that in Ruby, we can call zero-argument methods without parentheses, like so:

```ruby
def foo:
    puts "Hello, World!"
end
foo()
# -> Hello, World!
foo
# -> Hello, World!
```

This seems like a trivial convenience feature, but it's much more complicated than that, because it has implications for **parsing**.

When your code gets read into the Ruby interpreter, it has distinguish method calls from variable names in order to interpret your code correctly and unambiguously.

A variable will always shadow ("override") a method. Meaning if you have a local variable `foo` and a method `foo()`, `foo` will be treated as a variable dereference.

# Branch evaluation

Ruby runs through all branches before starting execution.

So it runs through all branches, gets to a variable name `x`, sees that we are assigning to it, realises it is therefore a variable name, and instantiates it with the value `nil`.

http://programmingisterrible.com/post/42432568185/how-to-parse-ruby
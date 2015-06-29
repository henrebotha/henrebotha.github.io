The principle of least astonishment is a guiding philosphy in the design of computer systems. Any operation, the principle says (roughly), should always have the least surprising result. It makes sense: computer systems are extremely complex, and if a user - or a developer - can't rely on her instincts, how can we expect her to use the system *at all*?

So on that note, consider the following Python code.

```python
if False:
    x = 5
print(x)
```

What do you expect the result to be? A `NameError`, of course! The always-false `if` statement prevents the assignment to `x` from ever occurring, and so when we attempt to print `x`, it doesn't exist.

What about Javascript?

```javascript
if(false) {
	x = 5;
}
console.log(x);
```

Wahey! `ReferenceError`!

...Now what would Ruby do, do you think?

```ruby
if false
	x = 5
end
puts x
```

Surprise, surprise: it returns `nil`, instead of a `NameError` as any person who's ever used an interpreted language might expect.

This is not a minor issue, either: last week, we discovered it to be the cause of a bug that prevented an entire feature on our site from working.

So what on Earth is the rationale here? How is Ruby able to see the variable that exists inside a block that *never executes*?

---

http://programmingisterrible.com/post/42432568185/how-to-parse-ruby
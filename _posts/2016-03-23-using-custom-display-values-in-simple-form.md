---
layout: post
title: Using custom display values in Simple Form
date: 2016-03-23 21:43:00
tags: [ruby, rails, simple form]
---
[Simple Form](https://github.com/plataformatec/simple_form) is a popular library for Rails that makes it easy to generate forms using a simple DSL, while adding high customisability.

I had to create a dropdown `select` element today where the display values had to be different to the actual values selected behind the scenes. Checking the docs, I found that Simple Form has a `label_method` property that can be used for just this purpose, though they don't explicitly explain how. I tinkered around with it and figured it out, so for posterity, here is an example:

```ruby
simple_form_for @qualification do |f|
    = f.input :year_of_study,
        collection: 1..4,
        label_method: ->(i) { i == 4 ? "final year" | "#{i.ordinalize} year" }
```

This example would result in a `select` that selects from `[1, 2, 3, 4]`, but displays `["1st year", "2nd year", "3rd year", "final year"]`.

This is a rather nifty feature and I'm surprised they don't document it a bit better, but hey, now you know. :)

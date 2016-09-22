---
layout: post
title: Setting Rails asset domains inline
date: 2016-09-22 10:00:00 +0200
tags: [ruby, rails, quickie]
---
Rails provides a set of view helpers for including assets on a page: `image_tag`, `javascript_include_tag`, and `stylesheet_link_tag`. These make use of your host domain as set in your Rails configuration via `config.action_controller.host`.

Those helpers are pretty clever - you can specify a full URL, or you can just give it a string like `front` and the helper will expand that to `http://my.website/assets/javascripts/front.js`. Better yet, if you're using the Rails asset pipeline, the latter case will make sure to append the generated MD5 hash to grab the correct version of the file.

Where the helper fails is if you are using the asset pipeline, and want to point a particular helper at a resource hosted on a different domain to the one you configured, but still using the asset pipeline hash. (Don't ask me why I needed to do this at Travelstart, but I did.)

If you find yourself challenged to do this, the `asset_url` helper comes to your rescue:

```ruby
javascript_include_tag(asset_url('front', host: 'special_resource.website'))
```

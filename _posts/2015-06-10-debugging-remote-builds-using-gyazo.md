---
layout: post
title: Debugging remote builds using Gyazo
date: 2015-06-10 19:16:00
tags: [ruby, rails, capybara, rspec, semaphore, gyazo]
---
At Leaply, we use Capybara and Poltergeist to run integration tests. Sometimes, we find that our specs don't give enough information to determine why a test failed, and when we run them on Semaphore, it's especially hard to troubleshoot the cause as we don't have access to screenshots after the fact.

Gyazo is a social screenshot application, popular with gamers, that is used to take and share screenshots online. It turns out they have a nice API, so I thought this would be a great way for us to send ourselves screenshots from inside Semaphore, without having to worry about where to save the files or how to retrieve them.

What makes Gyazo so convenient is that they handle the hosting using anonymised URLs. There's no way for someone to stumble on our screenshots, and we can access the screens from any device without needing to use authentication, so it's a really neat solution.

We use Slack for team communication, so I set our tests up so that, if they fail, they post the error report and a link to the final screenshot to a Slack channel.

Once you've registered at Gyazo, head [here](https://gyazo.com/oauth/applications) to register your app and get your access token. Then head on over to Slack and configure the Incoming WebHooks integration to receive your messages.

You'll need the gems `gyazo` and `slack-notifier` for this. Add each to your Gemfile, do `bundle install`, and then simply add the following to each spec file:

```ruby
after :each do |example|
    if ENV["SEMAPHORE"] and example.exception
        gyazo_screenshot(example)
    end
end
```

You can define the `gyazo_screenshot` method in `feature_helper.rb`:

```ruby
def gyazo_screenshot(example)
    gyazo = Gyazo::Client.new(
        '99c2d9ae513cde365c25598fcd011cbcd882728d511dab61c2e38571c182c8c1'
    ) # your access token
    notifier = Slack::Notifier.new(
        "https://hooks.slack.com/services/CaTd6YeRd/WDj7cfNOD/srwGKrg724rpMpnUQReE6dLP",
        username: 'Gyazo'
    ) # use your slack URL here

    fail_screen = save_screenshot("test failed.jpg")
    res = gyazo.upload fail_screen

    notification = "*Spec failed:* #{example.full_description}"
    notification += "\n#{example.location}:\n>#{example.exception}"
    notification += "\n<#{res['permalink_url']} | Click to view screenshot.>"

    notifier.ping notification, icon_emoji: ":sob:"
end
```

And that's it! Whenever a spec fails, it will send you a Gyazo link via Slack, which will contain a screengrab of the app as it was when it failed. Super useful for debugging flaky tests.
# AliyunSms

阿里云短信服务（Short Message Service）对接gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aliyun_sms', git: "git@github.com:as181920/aliyun_sms.git", branch: "master"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aliyun_sms

## Usage

ApiClient.new(access_key_id, access_key_secret).send_message(template_id, params)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aliyun_sms.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


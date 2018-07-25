# Instagram::API

Welcome to Instagram-API gem! implemented from [huttarichard/instagram-private-api](https://github.com/huttarichard/instagram-private-api)
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ig_api'
```

And then execute:

    $ bundle

## Usage
 - Login _for new user_
 ```ruby
account = IgApi::Account.new

user = account.login 'username', 'password' #login
user.feed.timeline_media #timeline media
search = user.search_for_user 'instagram' #search
user.relationship.create search.id #follow
```
- Rails
```ruby
class HomeController < ApplicationController
  def index
    account = IgApi::Account.new

    @user = account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
    render :json => @user
  end
end

```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing
testcase is using real instagram account, you can safely store your credential in environment variables.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/vicoerv/Instagram-API](https://github.com/vicoerv/instagram-private-api). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Instagram::API project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/vicoerv/instagram-private-api/blob/master/CODE_OF_CONDUCT.md).
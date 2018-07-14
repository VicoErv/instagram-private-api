# Instagram::API

Welcome to Instagram-API gem! This Gem is implemented from [huttarichard/instagram-private-api](https://github.com/huttarichard/instagram-private-api) the best `Node-JS` Insgtagram private API
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'instagram-private-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install instagram-private-api

## Usage
 - Login _for clearly new user_
 ```ruby
 user = Instagram::Account.login 'username', 'password'
 ```
 
 - Initiate existing user
 ```ruby
 logged_in_user = User.find(id: 1) #User as Model
 data = {}
 data[:id] = logged_in_user.pk
 data[:full_name] = logged_in_user.full_name
 data[:is_private] = logged_in_user.is_private
 data[:profile_pic_url] = logged_in_user.profile_pic_url
 data[:profile_pic_id] = logged_in_user.profile_pic_id
 data[:is_verified] = logged_in_user.is_verified
 data[:is_business] = logged_in_user.is_business
 session = logged_in_user.session
 
 user = Instagram::User.new 'username', nil, data, session #password isn't mandatory, already have session
 p user.search_for_user 'instagram' #then you can use it for any purpose
 ```
 
 - Search for user
 ```ruby
 p user.search_for_user 'instagram'
 ```
 
 - User feed
 ```ruby
 p user.media #your feed
 
 user_target = user.search_for_user 'instagram'
 p user.media user_id: user_target.data[:id] #instagram feed, or
 media = user_target.media #instagram feed as shorthand
 if media['next_available']
    p user_target.media max_id: media['next_max_id'] #next page
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
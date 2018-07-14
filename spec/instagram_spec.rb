require 'rspec'
require 'Instagram'

describe 'Instagram' do

  it 'login' do
    user = Instagram::Account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
    p user.feed
  end
end
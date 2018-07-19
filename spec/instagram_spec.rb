require 'rspec'
require 'Instagram'

describe 'Instagram' do

  it 'should login' do
    account = Instagram::Account.new

    user = account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
    search = user.search_for_user('instagram')
    instagram_id = search.data[:id]
    user.relationship.create instagram_id
    user.feed.timeline_media
  end
end
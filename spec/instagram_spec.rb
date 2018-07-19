require 'rspec'
require 'Instagram'

describe 'Instagram' do

  it 'login' do
    account = Instagram::Account.new

    user = account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
    instagram = user.search_for_user('instagram')
    instagram_id = instagram.data[:id]
    response = user.relationship.create instagram_id

    p response
  end
end
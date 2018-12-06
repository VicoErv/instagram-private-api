require 'rspec'
require 'ig_api'

describe 'ig_api' do
  it 'should login' do
    # p IgApi::Media.get_id_from_code 'BlvwDHwFSgy'
    account = IgApi::Account.new
    @user = account.using ENV['INSTAGRAM_SESSION']

    expect(@user).to be_instance_of IgApi::User

    @search = @user.info_by_name'vicoerv'
    @user_id = @search.user.pk

    media = IgApi::Media.new(@user)
    likes = media.like('1735389257830282125_1626347005')

    @user.timeline_media
  end
end
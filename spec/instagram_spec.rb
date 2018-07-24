require 'rspec'
require 'ig_api'

describe 'ig_api' do
  # it 'should login' do
  #   account = ig_api::Account.new
  #
  #   user = account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
  #   search = user.search_for_user('instagram')
  #   instagram_id = search.data[:id]
  #   follow = user.relationship.create instagram_id
  #   timeline = user.feed.timeline_media
  #
  #   unfollow = user.relationship.destroy instagram_id
  # end

  before(:each) do
    account = IgApi::Account.new

    @user = account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
    @search = @user.search_for_user('instagram')
    @instagram_id = @search.data[:id]
    @follow = @user.relationship.create @instagram_id
    @unfollow = @user.relationship.destroy @instagram_id
    @timeline = @user.feed.timeline_media
  end

  it 'should login' do
    p @user
    @user.is_a? IgApi::User.class
  end

  it 'should search' do
    @search.is_a? IgApi::User.class
  end

  it 'should instagram id' do
    @instagram_id === 25025320
  end

  it 'should follow' do
    p @follow
  end
end
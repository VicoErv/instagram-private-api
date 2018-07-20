require 'rspec'
require 'Instagram'

describe 'Instagram' do
  # it 'should login' do
  #   account = Instagram::Account.new
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
    account = Instagram::Account.new
    @user = account.login ENV['INSTAGRAM_USER'], ENV['INSTAGRAM_PASSWORD']
    @search = @user.search_for_user('instagram')
    @instagram_id = @search.data[:id]
    @follow = @user.relationship.create @instagram_id
    @unfollow = @user.relationship.destroy @instagram_id
    @timeline = @user.feed.timeline_media
  end

  it 'should login' do
    @user.is_a? Instagram::User.class
  end

  it 'should search' do
    @search.is_a? Instagram::User.class
  end

  it 'should instagram id' do
    @instagram_id === 25025320
  end

  it 'should follow' do
    p @follow
  end
end
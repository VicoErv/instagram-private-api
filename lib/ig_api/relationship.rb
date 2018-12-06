# frozen_string_literal: true
require 'ostruct'

module IgApi
  class Relationship
    def initialize user
      @user = user
      @api = nil
    end

    def create(id)
      JSON.parse api.post("https://i.instagram.com/api/v1/friendships/create/#{id}/",
                          format(
                            'ig_sig_key_version=4&signed_body=%s',
                            Http.generate_signature(
                              user_id: id
                            )
                          )).with(session: @user.session, ua: @user.useragent)
                            .exec.body, object_class: OpenStruct
    end

    def destroy(id)
      JSON.parse api.post("https://i.instagram.com/api/v1/friendships/destroy/#{id}/",
                          format(
                            'ig_sig_key_version=4&signed_body=%s',
                            Http.generate_signature(
                              user_id: id
                            )
                          )).with(session: @user.session, ua: @user.useragent)
                            .exec.body, object_class: OpenStruct
    end

    def api
      @api = Http.new if @api.nil?

      @api
    end
  end
end

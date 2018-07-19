# frozen_string_literal: true

module Instagram
  class Relationship
    def initialize user
      @user = user
      @api = nil
    end

    def create(id)
      api.post("https://i.instagram.com/api/v1/friendships/create/#{id}/",
               format(
                 'ig_sig_key_version=4&signed_body=%s',
                 V1.generate_signature(
                   user_id: id
                 )
               )).with(session: @user.session, ua: @user.useragent).exec
    end

    def api
      @api = V1.new if @api.nil?

      @api
    end
  end
end

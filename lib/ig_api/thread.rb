module IgApi
  class Thread
    def initialize
      @api = Http.singleton
    end

    def using(user)
      @user = {
        session: user.session,
        ua: user.useragent
      }

      self
    end

    def configure_text(users, text)
      body = {
        recipient_users: [users].to_json,
        client_context: Http.generate_uuid,
        text: text
      }

      response = @api.multipart(Constants::URL + 'direct_v2/threads/broadcast/text/',
                           body)
                     .with(ua: @user[:ua], session: @user[:session])
                     .exec

      response.body
    end
  end
end

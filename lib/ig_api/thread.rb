require 'uri'
require 'net/http/post/multipart'

module IgApi
  class Thread
    def initialize
      @api = Http.singleton
    end

    def using(user)
      @user = {
        id: user.data[:id],
        session: user.session,
        ua: user.useragent
      }

      self
    end

    def configure_text(users, text)
      uris = URI.extract(text, %w[http https])
      broadcast = 'text'

      body = {
        recipient_users: [users].to_json,
        client_context: Http.generate_uuid,
      }

      if uris.empty?
        body[:text] = text
      else
        broadcast = 'link'
        body[:link_text] = text
        body[:link_urls] = uris.to_json
      end

      response = @api.multipart(Constants::URL +
                                    "direct_v2/threads/broadcast/#{broadcast}/",
                                body)
                     .with(ua: @user[:ua], session: @user[:session])
                     .exec

      response.body
    end

    def configure_media(users, media_id, text)
      payload = {
        recipient_users: [users].to_json,
        client_context: IgApi::Http.generate_uuid,
        media_id: media_id
      }

      payload[:text] = text unless text.empty?
      response = @api.multipart(Constants::URL + 'direct_v2/threads/broadcast/media_share/?media_type=photo',
                                payload)
                     .with(session: @user[:session], ua: @user[:ua])
                     .exec

      response.body
    end

    def configure_story(users, media_id, text)
      payload = {
          action: 'send_item',
          _uuid: IgApi::Http.generate_uuid,
          client_context: IgApi::Http.generate_uuid,
          recipient_users: [users].to_json,
          story_media_id: media_id,
          reel_id: media_id.split('_')[1],
          text: text
      }

      signature = Http.generate_signature payload

      response = @api.post(
        Constants::URL + 'direct_v2/threads/broadcast/story_share/',
        "ig_sig_key_version=4&signed_body=#{signature}"
      )
                     .with(ua: @user[:ua], session: @user[:session])
                     .exec

      response.body
    end
  end
end

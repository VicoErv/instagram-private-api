require 'ostruct'

module IgApi
  class Feed
    def initialize
      @api = Http.singleton
    end

    def using user
      @user = {
        id: user.data[:id],
        session: user.session,
        ua: user.useragent
      }
      self
    end

    def story(ids)
      signature = IgApi::Http.generate_signature(
        user_ids: ids.map(&:to_s)
      )
      response = @api.post(Constants::URL + 'feed/reels_media/',
                           "ig_sig_key_version=4&signed_body=#{signature}")
                     .with(session: @user[:session], ua: @user[:ua])
                     .exec

      response.body
    end

    def timeline_media
      user_id = @user[:id]

      rank_token = IgApi::Http.generate_rank_token @user[:id]
      endpoint = "https://i.instagram.com/api/v1/feed/user/#{user_id}/"
      result = @api.get(endpoint + "?rank_token=#{rank_token}")
                   .with(session: @user[:session], ua: @user[:ua]).exec

      JSON.parse result.body, object_class: OpenStruct
    end

    def self.user_followers(user, data, limit)
      has_next_page = true
      followers = []
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      data[:rank_token] = IgApi::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      while has_next_page && limit > followers.size
        response = user_followers_next_page(user, user_id, data)
        has_next_page = !response['next_max_id'].nil?
        data[:max_id] = response['next_max_id']
        followers += response['users']
      end
      limit.infinite? ? followers : followers[0...limit]
    end

    def self.user_followers_next_page(user, user_id, data)
      endpoint = "https://i.instagram.com/api/v1/friendships/#{user_id}/followers/"
      param = "?rank_token=#{data[:rank_token]}" +
              (!data[:max_id].nil? ? '&max_id=' + data[:max_id] : '')
      result = IgApi::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user
      )
      JSON.parse result.body, object_class: OpenStruct
    end
  end
end

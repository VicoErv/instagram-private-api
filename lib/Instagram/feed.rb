module Instagram
  module Feed
    def self.user_media(user, data)
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      rank_token = Instagram::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = "https://i.instagram.com/api/v1/feed/user/#{user_id}/"
      param = "?rank_token=#{rank_token}" +
              (!data[:max_id].nil? ? '&max_id=' + data[:max_id] : '')
      result = Instagram::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user
      )

      JSON.parse result.body
    end

    def self.user_followers(user, data, limit)
      has_next_page = true
      followers = []
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      data[:rank_token] = Instagram::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      while has_next_page && limit > followers.size
        result = user_followers_next_page(user, user_id, data)
        has_next_page = !result['next_max_id'].nil?
        data[:max_id] = result['next_max_id']
        followers += result['users']
      end
      limit.infinite? ? followers : followers[0...limit]
    end

    def self.user_followers_next_page(user, user_id, data)
      endpoint = "https://i.instagram.com/api/v1/friendships/#{user_id}/followers/"
      param = "?rank_token=#{data[:rank_token]}" +
              (!data[:max_id].nil? ? '&max_id=' + data[:max_id] : '')
      result = Instagram::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user
      )
      JSON.parse result.body
    end
  end
end

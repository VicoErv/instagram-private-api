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
  end
end

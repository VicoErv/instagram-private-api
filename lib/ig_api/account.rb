require 'ostruct'

module IgApi
  class Account
    def initialized
      @api = nil
    end

    def api
      @api = IgApi::Http.new if @api.nil?

      @api
    end

    def using(session)
      User.new session: session
    end

    def login(username, password, config = IgApi::Configuration.new)
      user = User.new username: username,
                      password: password

      request = api.post(
        Constants::URL + 'accounts/login/',
        format(
          'ig_sig_key_version=4&signed_body=%s',
          IgApi::Http.generate_signature(
            device_id: user.device_id,
            login_attempt_user: 0, password: user.password, username: user.username,
            _csrftoken: 'missing', _uuid: IgApi::Http.generate_uuid
          )
        )
      ).with(ua: user.useragent).exec

      response = JSON.parse request.body, object_class: OpenStruct

      raise response.message if response.status == 'fail'

      logged_in_user = response.logged_in_user
      user.data = logged_in_user

      cookies_array = []
      all_cookies = request.get_fields('set-cookie')
      all_cookies.each do |cookie|
        cookies_array.push(cookie.split('; ')[0])
      end
      cookies = cookies_array.join('; ')
      user.config = config
      user.session = cookies

      user
    end

    def self.search_for_user_graphql(user, username)
      endpoint = "https://www.instagram.com/#{username}/?__a=1"
      result = IgApi::API.http(url: endpoint, method: 'GET', user: user)

      response = JSON.parse result.body, symbolize_names: true, object_class: OpenStruct
      return nil unless response.user.any?
    end

    def search_for_user(user, username)
      rank_token = IgApi::Http.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = 'https://i.instagram.com/api/v1/users/search/'
      param = format('?is_typehead=true&q=%s&rank_token=%s', username, rank_token)
      result = api.get(endpoint + param)
                   .with(session: user.session, ua: user.useragent).exec

      result = JSON.parse result.body, object_class: OpenStruct

      if result.num_results > 0
        user_result = result.users[0]
        user_object = IgApi::User.new username: username
        user_object.data = user_result
        user_object.session = user.session
        user_object
      end
    end

    def list_direct_messages(user, limit = 100)
      base_url = 'https://i.instagram.com/api/v1'
      rank_token = IgApi::Http.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]

      endpoint = base_url + "/direct_v2/inbox/?persistentBadging=true&use_unified_inbox=true&show_threads=true&limit=#{limit}"
      param = format('&is_typehead=true&q=%s&rank_token=%s', user.username, rank_token)

      result = api.get(endpoint + param).with(session: user.session, ua: user.useragent).exec
      result = JSON.parse result.body, object_class: OpenStruct

      # fetch + combine past messages from parent thread
      all_messages = []
      result.inbox.threads.each do |thread|
        # thread_id = thread.thread_v2_id # => 17953972372244048 DO NOT USE V2!
        thread_id = thread.thread_id # => 340282366841710300949128223810596505168
        cursor_id = thread.oldest_cursor # '28623389310319272791051433794338816'

        thread_endpoint = base_url + "/direct_v2/threads/#{thread_id}/?cursor=#{cursor_id}"
        param = format('&is_typehead=true&q=%s&rank_token=%s', user.username, rank_token)

        result = api.get(thread_endpoint + param).with(session: user.session, ua: user.useragent).exec
        result = JSON.parse result.body, object_class: OpenStruct

        if result.thread && result.thread.items.count > 0
          older_messages = result.thread.items.sort_by(&:timestamp) # returns oldest --> newest
          all_messages << {
            thread_id: thread_id,
            recipient_username: thread.users.first.username, # possible to have 1+
            conversations: older_messages << thread.items.first
          }
        end
      end

      all_messages
    end
  end
end

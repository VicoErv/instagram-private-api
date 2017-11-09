require 'Instagram/API/version'
require 'openssl'
require 'Base64'
require 'digest/md5'
require 'net/http'
require 'json'
require 'Instagram/User'

module Instagram
  module API
    def self.lookup_user(username, max_id)
      ;
    end

    def self.compute_hash(data)
      OpenSSL::HMAC.hexdigest OpenSSL::Digest.new('sha256'), CONSTANTS::PRIVATE_KEY[:SIG_KEY], data
    end

    def self.generate_uuid
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.gsub(/[xy]/) do |c|
        r = (Random.rand * 16).round | 0
        v = c == 'x' ? r : (r & 0x3 | 0x8)
        c.gsub(c, v.to_s(16))
      end.downcase
    end

    def self.create_md5(data)
      Digest::MD5.hexdigest(data).to_s
    end

    def self.generate_device_id
      timestamp = Time.now.to_i.to_s
      'android-' + create_md5(timestamp)[0..16]
    end

    def self.generate_signature(data)
      data = data.to_json
      compute_hash(data) + '.' + data
    end

    def self.http (args)
      args[:url] = URI.parse(args[:url])
      http = Net::HTTP.new(args[:url].host, args[:url].port, '127.0.0.1', '8888')
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = nil
      if args[:method] == 'POST'
        request = Net::HTTP::Post.new(args[:url].path)
      elsif args[:method] == 'GET'
        request = Net::HTTP::Get.new(args[:url].path + (!args[:url].nil? ? '?' + args[:url].query : ''))
      end

      request.initialize_http_header(
          :'User-Agent' => args[:user].useragent,
          :Accept => Instagram::CONSTANTS::HEADER[:accept],
          :'Accept-Encoding' => Instagram::CONSTANTS::HEADER[:encoding],
          :'Accept-Language' => args[:user].language,
          :'X-IG-Capabilities' => Instagram::CONSTANTS::HEADER[:capabilities],
          :'X-IG-Connection-Type' => Instagram::CONSTANTS::HEADER[:type],
          :Cookie => (args[:user].session.nil? ? '' : args[:user].session))
      request.body = args.key?(:body) ? args[:body] : nil
      http.request(request)
    end

    module Account
      def self.login(user)
        request = Instagram::API.http(
                                    url:CONSTANTS::URL + 'accounts/login/',
                                    method:'POST',
                                    user: user,
                                    body: format('ig_sig_key_version=4&signed_body=%s', Instagram::API.generate_signature(device_id: user.device_id,
                                                                                                                    login_attempt_user: 0, password: user.password, username: user.username,
                                                                                                                    _csrftoken: 'missing', _uuid: Instagram::API.generate_uuid))
        )
        json_body = JSON.parse request.body
        logged_in_user = json_body['logged_in_user']
        user.data = {}
        user.data[:id] = logged_in_user['pk']
        user.data[:full_name] = logged_in_user['full_name']
        user.data[:is_private] = logged_in_user['is_private']
        user.data[:profile_pic_url] = logged_in_user['profile_pic_url']
        user.data[:profile_pic_id] = logged_in_user['profile_pic_id']
        user.data[:is_verified] = logged_in_user['is_verified']
        user.data[:is_business] = logged_in_user['is_business']
        cookies_array = Array.new
        all_cookies = request.get_fields('set-cookie')
        all_cookies.each { | cookie |
          cookies_array.push(cookie.split('; ')[0])
        }
        cookies = cookies_array.join('; ')
        user.session = cookies
      end

      def self.search_for_user (user, username)
        pk = user.session.scan(/ds_user_id=([\d]+);/)[0][0]
        rank_token = '%s_%s' % [pk, Instagram::API.generate_uuid]
        endpoint = 'https://i.instagram.com/api/v1/users/search/'
        param = '?is_typehead=true&q=%s&rank_token=%s' % [username, rank_token]
        Instagram::API.http(
                          url: endpoint + param,
                          method: 'GET',
                          user: user
        )
      end
    end
  end
end

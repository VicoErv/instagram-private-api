require 'Instagram/API/version'
require 'openssl'
require 'Base64'
require 'digest/md5'
require 'net/http'
require 'json'
require 'Instagram/User'

module Instagram
  module API

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

    module Accounts
      def self.login(user)
        url = URI.parse(CONSTANTS::URL + 'accounts/login/')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        post = Net::HTTP::Post.new(url.path,
                                   :Accept => CONSTANTS::HEADER[:accept],
                                   :'Accept-Encoding' => CONSTANTS::HEADER[:encoding],
                                   :'Accept-Language' => user.language,
                                   :Connection => CONSTANTS::HEADER[:connection],
                                   :Host => CONSTANTS::HEADER[:host],
                                   :'X-IG-Capabilities' => CONSTANTS::HEADER[:capabilities],
                                   :'X-IG-Connection-Type' => CONSTANTS::HEADER[:type])
        post.initialize_http_header(:'User-Agent' => user.useragent)
        post.body = 'ig_sig_key_version=4&signed_body=%s' %
            [Instagram::API.generate_signature(device_id: user.device_id,
            login_attempt_user: 0, password: user.password, username: user.username,
            _csrftoken: 'missing', _uuid: Instagram::API.generate_uuid)]
        request = http.request(post)
        request.body
      end
    end
  end
end

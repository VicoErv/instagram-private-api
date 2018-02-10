require 'Instagram/API/version'
require 'openssl'
require 'Base64'
require 'digest/md5'
require 'net/http'
require 'json'
require 'Instagram/User'
require 'Instagram/account'
require 'Instagram/feed'
require 'Instagram/Configuration'

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

    def self.http(args)
      args[:url] = URI.parse(args[:url])
      http = Net::HTTP.new(args[:url].host, args[:url].port, ENV['INSTAGRAM_PROXY_HOST'], ENV['INSTAGRAM_PROXY_PORT'])
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = nil
      if args[:method] == 'POST'
        request = Net::HTTP::Post.new(args[:url].path)
      elsif args[:method] == 'GET'
        request = Net::HTTP::Get.new(args[:url].path + (!args[:url].nil? ? '?' + args[:url].query : ''))
      end

      request.initialize_http_header(:'User-Agent' => args.dig(:user)&.useragent,
                                     :Accept => Instagram::CONSTANTS::HEADER[:accept],
                                     :'Accept-Encoding' => Instagram::CONSTANTS::HEADER[:encoding],
                                     :'Accept-Language' => args.dig(:user)&.language,
                                     :'X-IG-Capabilities' => Instagram::CONSTANTS::HEADER[:capabilities],
                                     :'X-IG-Connection-Type' => Instagram::CONSTANTS::HEADER[:type],
                                     :Cookie => (args.dig(:user)&.session.nil? ? '' : args.dig(:user)&.session))
      request.body = args.key?(:body) ? args[:body] : nil
      http.request(request)
    end

    def self.generate_rank_token(pk)
      format('%s_%s', pk, Instagram::API.generate_uuid)
    end
  end
end

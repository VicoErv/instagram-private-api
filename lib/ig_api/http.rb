# frozen_string_literal: true

require 'ig_api/version'
require 'openssl'
require 'net/http'
require 'json'
require 'ig_api/user'
require 'ig_api/account'
require 'ig_api/feed'
require 'ig_api/configuration'

module IgApi
  class Http
    def self.compute_hash(data)
      OpenSSL::HMAC.hexdigest OpenSSL::Digest.new('sha256'), Constants::PRIVATE_KEY[:SIG_KEY], data
    end

    def self.__obj=(value)
      @@obj = value
    end

    def self.__obj
      @@obj
    end

    def self.singleton
      @@obj = Http.new unless defined? @@obj

      @@obj
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
      hash = compute_hash(data) + '.' + data
      CGI.escape(hash)
    end

    def post(url, body = nil)
      @data = { method: 'POST', url: url, body: body }
      self
    end

    def multipart(url, body = nil)
      @data = { method: 'MULTIPART', url: url, body: body }
      self
    end

    def with(data)
      data.each { |k, v| @data[k] = v }
      self
    end

    def exec
      http @data
    end

    def get(url)
      @data = {method: 'GET', url: url}
      self
    end

    def http(args)
      args[:url] = URI.parse(args[:url])
      http = Net::HTTP.new(args[:url].host, args[:url].port,
                           ENV['INSTAGRAM_PROXY_HOST'], ENV['INSTAGRAM_PROXY_PORT'])
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = nil
      if args[:method] == 'POST'
        request = Net::HTTP::Post.new(args[:url].path)
      elsif args[:method] == 'GET'
        request = Net::HTTP::Get.new(args[:url].path + (!args[:url].query.nil? ? '?' + args[:url].query : ''))
      elsif args[:method] == 'MULTIPART'
        request = Net::HTTP::Post::Multipart.new args[:url].path, args[:body],
                                                 'User-Agent': args[:ua],
                                                 Accept: IgApi::Constants::HEADER[:accept],
                                                 'Accept-Encoding': IgApi::Constants::HEADER[:encoding],
                                                 'Accept-Language': 'en-US',
                                                 'X-IG-Capabilities': IgApi::Constants::HEADER[:capabilities],
                                                 'X-IG-Connection-Type': IgApi::Constants::HEADER[:type],
                                                 Cookie: args[:session] || ''
      end

      unless args[:method] == 'MULTIPART'
        request.initialize_http_header('User-Agent': args[:ua],
                                       Accept: IgApi::Constants::HEADER[:accept],
                                       'Accept-Encoding': IgApi::Constants::HEADER[:encoding],
                                       'Accept-Language': 'en-US',
                                       'X-IG-Capabilities': IgApi::Constants::HEADER[:capabilities],
                                       'X-IG-Connection-Type': IgApi::Constants::HEADER[:type],
                                       Cookie: args[:session] || '')

        request.body = args.key?(:body) ? args[:body] : nil
      end

      http.request(request)
    end

    def self.generate_rank_token(pk)
      format('%s_%s', pk, IgApi::Http.generate_uuid)
    end
  end
end

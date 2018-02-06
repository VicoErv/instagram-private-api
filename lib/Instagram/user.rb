require 'digest/md5'
require 'Instagram/Device'
require 'Instagram/CONSTANTS'

module Instagram
  class User
    attr_reader :username
    attr_reader :password
    attr_reader :language
    attr_reader :data
    attr_writer :data
    attr_reader :session
    attr_writer :session

    def initialize(username, password, session = nil, data = nil)
      @username = username
      @password = password
      @language = 'en_US'
      @session = session
      @data = data
    end

    def search_for_user (username)
      Instagram::Account.search_for_user(self, username)
    end

    def user_media(data = {})
      Instagram::Feed.user_media(self, data)
    end

    def user_followers(limit = Float::INFINITY, data = {})
      Instagram::Feed.user_followers(self, data, limit)
    end

    def md5
      Digest::MD5.hexdigest @username
    end

    def md5int
      (md5.to_i(32) / 10e32).round
    end

    def api
      (18 + (md5int % 5)).to_s
    end

    # @return [string]
    def release
      %w[4.0.4 4.3.1 4.4.4 5.1.1 6.0.1][md5int % 5]
    end

    def dpi
      %w[801 577 576 538 515 424 401 373][md5int % 8]
    end

    def resolution
      %w[3840x2160 1440x2560 2560x1440 1440x2560
         2560x1440 1080x1920 1080x1920 1080x1920][md5int % 8]
    end

    def info
      line = Device.devices[md5int % Device.devices.count]
      {
        manufacturer: line[0],
        device: line[1],
        model: line[2]
      }
    end

    def useragent_hash
      agent = [api + '/' + release, dpi + 'dpi',
               resolution, info[:manufacturer], info[:model], info[:device], @language]

      {
        agent: agent.join('; '),
        version: CONSTANTS::PRIVATE_KEY[:APP_VERSION]
      }
    end

    def useragent
      format('Instagram %s Android(%s)', useragent_hash[:version], useragent_hash[:agent].rstrip)
    end

    def device_id
      'android-' + md5[0..15]
    end
  end
end

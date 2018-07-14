# frozen_string_literal: true

module Instagram
  module CONSTANTS
    PRIVATE_KEY = {
        SIG_KEY: '0443b39a54b05f064a4917a3d1da4d6524a3fb0878eacabf1424515051674daa',
        SIG_VERSION: '4',
        APP_VERSION: '10.33.0'
    }.freeze

    HEADER = {
        capabilities: '3QI=',
        type: 'WIFI',
        host: 'i.instagram.com',
        connection: 'Close',
        encoding: 'gzip, deflate, sdch',
        accept: '*/*'
    }.freeze

    URL = 'https://i.instagram.com/api/v1/'
  end
end
# frozen_string_literal: true

module IgApi
  module Constants
    PRIVATE_KEY = {
      SIG_KEY: '673581b0ddb792bf47da5f9ca816b613d7996f342723aa06993a3f0552311c7d',
      SIG_VERSION: '4',
      APP_VERSION: '42.0.0.19.95'
    }.freeze

    HEADER = {
      capabilities: '3brTPw==',
      type: 'WIFI',
      host: 'i.instagram.com',
      connection: 'Close',
      encoding: 'gzip, deflate, sdch',
      accept: '*/*'
    }.freeze

    URL = 'https://i.instagram.com/api/v1/'
  end
end

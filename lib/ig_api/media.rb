require 'ostruct'

module IgApi
  class Media
    def self.get_id_from_code(code)
      alphabet = {
        '-': 62, '1': 53, '0': 52, '3': 55, '2': 54, '5': 57,
        '4': 56, '7': 59, '6': 58, '9': 91, '8': 60, 'A': 0,
        'C': 2, 'B': 1, 'E': 4, 'D': 3, 'G': 6, 'F': 5, 'I': 8,
        'H': 7, 'K': 10, 'J': 9, 'M': 12, 'L': 11, 'O': 14, 'N': 13,
        'Q': 16, 'P': 15, 'S': 18, 'R': 17, 'U': 20, 'T': 19, 'W': 22,
        'V': 21, 'Y': 24, 'X': 23, 'Z': 25, '_': 63, 'a': 26, 'c': 28,
        'b': 27, 'e': 30, 'd': 29, 'g': 32, 'f': 31, 'i': 34, 'h': 33,
        'k': 36, 'j': 35, 'm': 38, 'l': 37, 'o': 40, 'n': 39, 'q': 42,
        'p': 41, 's': 44, 'r': 43, 'u': 46, 't': 45, 'w': 48, 'v': 47,
        'y': 50, 'x': 49, 'z': 51
      }

      n = 0

      code.split(//).each do |c|
        n = n * 64 + alphabet[:"#{c}"]
      end

      n
    end

    def initialize(user)
      @user = user
      @api = Http.singleton
    end

    def create_like(media_id)
      response = @api.post(Constants::URL + "media/#{media_id}/like/")
          .with(ua: @user.useragent, session: @user.session)
          .exec

      JSON.parse response.body, object_class: OpenStruct
    end

    def like(media_id)
      response = @api.get(Constants::URL + "media/#{media_id}/likers/")
                     .with(ua: @user.useragent, session: @user.session)
                     .exec

      raise Exception, response['message'] if response['status'] == 'fail'

      JSON.parse response.body, object_class: OpenStruct
    end
  end
end


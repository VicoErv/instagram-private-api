module IgApi
  class Media
    def initialize(user)
      @user = user
      @api = Http.singleton
    end

    def create_like(media_id)
      response = @api.post(Constants::URL + "media/#{media_id}/like/")
          .with(ua: @user.useragent, session: @user.session)
          .exec

      JSON.parse response.body
    end

    def like(media_id)
      response = @api.get(Constants::URL + "media/#{media_id}/likers/")
                     .with(ua: @user.useragent, session: @user.session)
                     .exec

      raise Exception, response['message'] if response['status'] == 'fail'

      JSON.parse response.body
    end
  end
end
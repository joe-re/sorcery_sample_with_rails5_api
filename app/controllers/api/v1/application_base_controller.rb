module Api
  module V1
    class ApplicationBaseController < ::ApplicationController
      before_action :require_valid_token

      private

      def require_valid_token
        access_token = request.headers[:HTTP_ACCESS_TOKEN]
        head :unauthorized unless User.login?(access_token)
      end
    end
  end
end

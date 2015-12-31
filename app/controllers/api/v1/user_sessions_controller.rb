module Api
  module V1
    class UserSessionsController < ApplicationBaseController
      skip_before_action :require_valid_token, only: :create

      def create
        if user = login(login_user[:email], login_user[:password])
          render json: UserSerializer.new(user).as_json.merge(access_token: user.activate.access_token), status: :created
        else
          head :not_found
        end
      end

      def destroy
        access_token = request.headers[:HTTP_ACCESS_TOKEN]
        api_key = ApiKey.find_by_access_token(access_token)
        unless api_key
          head :not_found
          return
        end
        user = User.find(api_key.user_id)
        user.inactivate
        head :no_content
      end

      private

      def login_user
        params[:user]
      end
    end
  end
end

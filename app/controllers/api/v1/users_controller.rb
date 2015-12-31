module Api
  module V1
    class UsersController < ApplicationBaseController
      before_action :set_user, only: [:show, :edit, :update, :destroy]
      skip_before_action :require_valid_token, only: :create

      # GET /users.json
      def index
        users = User.all

        render json: {
          users: ActiveModel::ArraySerializer.new(
            users,
            each_serializer: UserSerializer
          ).to_json
        }
      end

      # GET /users/1.json
      def show
        unless @user
          head :not_found
          return
        end
        render json: @user
      end

      # POST /users.json
      def create
        user = User.new(user_params)

        if user.save
          render json: UserSerializer.new(user)
        else
          head :bad_request
        end
      end

      # PATCH/PUT /users/1.json
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # DELETE /users/1.json
      def destroy
        @user.destroy
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find_by_id(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.require(:user).permit(:email, :username, :password, :password_confirmation)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'user_sessions', type: :request do
  describe 'POST /api/v1/user_sessions' do
    let(:valid_params) do
      {
        user: {
          email: 'sample@ggg.com',
          password: 'password'
        }
      }
    end

    before do
      User.create(valid_params[:user].merge(username: 'sample', password_confirmation: 'password'))
      post '/api/v1/user_sessions', params: params
    end

    context 'parameters are valid' do
      let(:params) { valid_params }
      it 'create a user session and receive 201 and access_token' do
        expect(response.status).to eq 201
        expect(response.body).to have_json_path('access_token')
        expect(response.body).to have_json_type(String).at_path('access_token')
        expect(ApiKey.count).to eq 1
        expect(ApiKey.first.active).to be_truthy
      end
    end

    context 'password is wrong' do
      let(:params) do
        valid_params[:user][:password] = 'wrong'
        valid_params
      end
      it 'receive 404' do
        expect(response.status).to eq 404
      end
    end
  end

  describe 'DELETE /api/v1/user_sessions' do
    before do
      create_user_and_login
      delete '/api/v1/user_sessions', headers: { HTTP_ACCESS_TOKEN: @access_token }
    end

    it 'delete a user session and receive 204' do
      expect(response.status).to eq 204
      expect(ApiKey.count).to eq 1
      expect(ApiKey.first.active).to be_falsey
    end
  end
end

require 'rails_helper'

RSpec.describe 'users', type: :request do
  describe 'GET /api/v1/users' do
    context "don't login" do
      before { get '/api/v1/users' }
      it { expect(response.status).to eq 401 }
    end

    context 'has logined' do
      before do
        create_user_and_login
        get '/api/v1/users', headers: { HTTP_ACCESS_TOKEN: @access_token }
      end
      it 'receive 200 and user list' do
        expect(response.status).to eq 200
        expect(response.body).to have_json_path('users')
        expect(JSON.parse(response.body)['users'].count).to eq 1
        expect(response.body).to include_json([{ username: @user.username, email: @user.email }].to_json)
      end
    end
  end

  describe 'GET /api/v1/users/:user_id' do
    context "don't login" do
      before { get '/api/v1/users/1' }
      it { expect(response.status).to eq 401 }
    end

    context 'has logined' do
      before do
        create_user_and_login
        get "/api/v1/users/#{@user.id}", headers: { HTTP_ACCESS_TOKEN: @access_token }
      end
      it 'receive 200 and user' do
        expect(response.status).to eq 200
        expect(response.body).to have_json_path('user')
        expect(response.body).to eq UserSerializer.new(@user).to_json
      end
    end
  end

  describe 'PATCH /api/v1/users/:user_id' do
    context "don't login" do
      before { patch '/api/v1/users/1' }
      it { expect(response.status).to eq 401 }
    end

    context 'has logined' do
      let(:params) do
        {
          user: {
            username: 'changed_name',
            password: @password,
            password_confirmation: @password
          }
        }
      end
      before do
        create_user_and_login
        patch "/api/v1/users/#{@user.id}", params: params, headers: { HTTP_ACCESS_TOKEN: @access_token }
      end

      it 'receive 200 and update target user ' do
        expect(response.status).to eq 200
        expect(response.body).to have_json_path('user')
        expect(@user.reload.username).to eq 'changed_name'
        expect(response.body).to eq UserSerializer.new(@user).to_json
      end
    end
  end

  describe 'DELETE /api/v1/users/:user_id' do
    context "don't login" do
      before { delete '/api/v1/users/1' }
      it { expect(response.status).to eq 401 }
    end

    context 'has logined' do
      before do
        create_user_and_login
        delete "/api/v1/users/#{@user.id}", headers: { HTTP_ACCESS_TOKEN: @access_token }
      end

      it 'receive 204 and delete target user ' do
        expect(response.status).to eq 204
        expect(User.count).to eq 0
      end
    end
  end

  describe 'POST /api/v1/users' do
    let(:valid_params) do
      {
        user: {
          username: 'sample',
          email: 'sample@ggg.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end

    before { post '/api/v1/users', params: params }

    context 'paramters are valid' do
      let(:params) { valid_params }
      it 'create a new user and receive 201' do
        expect(response.status).to eq 201
        expect(User.count).to eq 1
        expect(response.body).to eq UserSerializer.new(User.first).to_json
      end
    end

    context 'password_confirmation is wrong' do
      let(:params) do
        valid_params[:user][:password_confirmation] = 'wrong'
        valid_params
      end

      it "doesn't create a user and receive 400" do
        expect(response.status).to eq 400
        expect(User.count).to eq 0
      end
    end
  end
end

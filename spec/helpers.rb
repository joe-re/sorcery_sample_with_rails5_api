module Helpers
  def create_user_and_login
    @password = 'password'
    @user = User.create(
      username: 'sample',
      email: 'sample@ggg.com',
      password: @password,
      password_confirmation: @password
    )

    post '/api/v1/user_sessions', params: { user: { email: 'sample@ggg.com', password: @password } }
    @access_token = JSON.parse(response.body)['access_token']
  end
end

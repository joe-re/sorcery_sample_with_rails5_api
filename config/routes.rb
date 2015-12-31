Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      resource :user_sessions, only: [:create, :destroy]

      get 'sample/public'
      get 'sample/restrict'
    end
  end
end

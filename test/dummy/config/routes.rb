Rails.application.routes.draw do
  root to: redirect("/rails_den/auth_probe")

  resource :registration, only: %i[new create edit update]
  resource :session
  resources :passwords, param: :token

  mount RailsDen::Engine => "/rails_den"
end

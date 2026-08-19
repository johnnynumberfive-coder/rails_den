Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  mount RailsDen::Engine => "/rails_den"
end

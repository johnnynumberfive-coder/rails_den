RailsDen::Engine.routes.draw do
  root to: "home#index"

  get "admin",
      to: "/admin/rails_den/administrators#index",
      as: :admin_root

  scope path: "admin", as: "admin" do
    scope as: "rails_den" do
      resources :administrators,
                controller: "/admin/rails_den/administrators"
    end
  end
end
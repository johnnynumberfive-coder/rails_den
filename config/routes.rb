RailsDen::Engine.routes.draw do
  root to: "home#index"

  resources :boards,
            only: :show

  get "admin",
      to: "/admin/rails_den/administrators#index",
      as: :admin_root

  scope path: "admin", as: "admin" do
    scope as: "rails_den" do
      resources :administrators,
                controller: "/admin/rails_den/administrators"

      resources :categories,
                controller: "/admin/rails_den/categories"

      resources :boards,
                controller: "/admin/rails_den/boards"
    end
  end
end
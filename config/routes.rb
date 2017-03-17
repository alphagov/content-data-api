Rails.application.routes.draw do
  root to: 'organisations#index'

  resources :groups, only: %w(show create)

  resources :organisations, only: %w(index)

  resources :content_items, only: %w(index show) do
    collection { get :filter }
  end
end

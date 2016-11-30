Rails.application.routes.draw do
  root to: 'organisations#index'

  resources :organisations, only: %w(index) do
    resources :content_items, only: %w(index)
  end
end

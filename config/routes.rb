Rails.application.routes.draw do
  root to: 'organisations#index'

  resources :organisations, only: %w(index)

  resources :content_items
end

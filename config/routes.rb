Rails.application.routes.draw do
  root to: 'organisations#index'

  resources :organisations, only: %w(index), param: :slug do
    resources :content_items, only: %w(index show)
  end
end

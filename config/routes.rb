Rails.application.routes.draw do
  root to: 'organisations#index'

  resources :organisations, only: %w(index)
end

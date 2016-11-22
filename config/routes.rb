Rails.application.routes.draw do

  resources :organisations, only: %w(index)

end

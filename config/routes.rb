Rails.application.routes.draw do
  root to: 'organisations#index'

  resources :groups, only: %w(show create index), param: "slug"

  resources :organisations, only: %w(index)

  resources :content_items, only: %w(index show), param: "content_id" do
    collection { get :filter }
  end
end

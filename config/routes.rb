Rails.application.routes.draw do
  root to: 'content_items#index'

  resources :groups, only: %w(show create index destroy), param: "slug"

  resources :content_items, only: %w(index show)

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end

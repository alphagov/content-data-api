Rails.application.routes.draw do
  root to: 'items#index'

  resources :items, only: %w(index show), param: :content_id

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end

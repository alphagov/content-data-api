Rails.application.routes.draw do
  root to: 'items#index'

  resources :items, only: %w(index show), param: :content_id

  get '/api/v1/metrics/:content_id', to: "metrics#show"
  
  get '/audits', to: redirect(Plek.find('content-audit-tool', status: 302))

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end

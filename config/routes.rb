Rails.application.routes.draw do
  root to: 'items#index'

  resources :items, only: %w(index show), param: :content_id

  get '/audits', to: redirect(Plek.find('content-audit-tool', status: 302))

  namespace :api, defaults: { format: :json } do
    get '/v1/metrics/:content_id', to: "metrics#show"
  end

  get '/sandbox', to: 'sandbox#index'
end

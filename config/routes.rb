Rails.application.routes.draw do
  root to: 'items#index'

  resources :items, only: %w(index show), param: :content_id

  get '/audits', to: redirect(Plek.find('content-audit-tool', status: 302))

  namespace :api, defaults: { format: :json } do
    get '/v1/organisations/:organisation_id/:metric/', to: "organisations#summary"

    get '/v1/metrics/:metric/:content_id/', to: "metrics#summary"
    get '/v1/metrics/:metric/:content_id/time-series', to: "metrics#time_series"

    get '/v1/healthcheck', to: "healthcheck#index"
  end

  get '/sandbox', to: 'sandbox#index'
end

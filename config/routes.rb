Rails.application.routes.draw do
  root to: 'items#index'

  resources :items, only: %w(index show), param: :content_id

  get '/audits', to: redirect(Plek.find('content-audit-tool', status: 302))

  namespace :api, defaults: { format: :json } do
    get '/v1/metrics/', to: "metrics#index"
    get '/v1/healthcheck', to: "healthcheck#index"
    get '/v1/organisations', to: 'organisations#index'
    get '/v1/document_types', to: 'document_types#index'
  end

  get '/content', to: 'content#show', defaults: { format: :json }
  get '/single_page/(*base_path)', to: 'single_item#show', defaults: { format: :json }, format: false
  get '/healthcheck', to: GovukHealthcheck.rack_response(
    Healthchecks::MonthlyAggregations,
    Healthchecks::DailyMetricsCheck,
    Healthchecks::DatabaseConnection,
    Healthchecks::SidekiqRetrySize,
    Healthchecks::EtlGoogleAnalytics.build(:pviews),
    Healthchecks::EtlGoogleAnalytics.build(:upviews),
    Healthchecks::EtlGoogleAnalytics.build(:searches),
    Healthchecks::EtlGoogleAnalytics.build(:feedex),
    Healthchecks::SearchAggregations.build(:last_month),
    Healthchecks::SearchAggregations.build(:last_six_months),
    Healthchecks::SearchAggregations.build(:last_thirty_days),
    Healthchecks::SearchAggregations.build(:last_three_months),
    Healthchecks::SearchAggregations.build(:last_twelve_months),
  )
end

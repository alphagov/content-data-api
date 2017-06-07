Rails.application.routes.draw do
  root to: 'content_items#index'

  resources :groups, only: %w(show create index destroy), param: "slug"

  resources :content_items, only: %w(index show) do
    get :audit, to: "audits#show"
    post :audit, to: "audits#save"
    patch :audit, to: "audits#save"
  end

  resources :audits, only: %w(index)

  resources :taxonomy_projects, path: '/taxonomy-projects', only: %w(index show) do
    get '/start' => 'taxonomy_todos#redirect_to_first'
  end

  resources :taxonomy_todos, only: %w(show update)

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end

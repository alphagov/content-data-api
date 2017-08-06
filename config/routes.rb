Rails.application.routes.draw do
  root to: 'content_items#index'

  resources :content_items, only: %w(index show), param: :content_id

  resources :content_items, only: %w(index show), param: :content_id do
    scope module: "audits" do
      get :audit, to: "audits#show"
      post :audit, to: "audits#save"
      patch :audit, to: "audits#save"
    end
  end

  namespace :audits do
    get '/', to: "audits#index"
    resource :report, only: :show
    resource :guidance, only: :show
  end

  namespace :inventory do
    root action: "show"
    get :toggle, action: "toggle"
    post :themes, action: "add_theme"
    post :subthemes, action: "add_subtheme"
  end

  resources :taxonomy_projects, path: '/taxonomy-projects', only: %w(index show new create) do
    get 'next', on: :member
  end

  resources :taxonomy_todos, only: %w(show update) do
    post 'dont_know', on: :member
    post 'not_relevant', on: :member
  end

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end

  class ProxyAccessContraint
    def matches?(request)
      !request.env['warden'].try(:user).nil?
    end
  end

  mount Proxies::IframeAllowingProxy.new => Proxies::IframeAllowingProxy::PROXY_BASE_PATH, constraints: ProxyAccessContraint.new
end

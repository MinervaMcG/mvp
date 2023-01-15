require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  # Admin area
  constraints Clearance::Constraints::SignedIn.new { |user| user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
    mount Blazer::Engine, at: "data-analytics"
  end
  # end Admin

  # Public API
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :supporters, only: [:index]
      resources :talent, only: [:show]
      get "/public_talent" => "talent#public_index"

      resource :username, only: [] do
        get :valid, on: :collection
      end

      resources :users, only: [:show] do
        namespace :profile do
          resources :community, only: [:index]
          resources :perks, only: [:index]

          scope :web3 do
            get :tokens, to: "web3#tokens"
            get :nfts, to: "web3#nfts"
            get :poaps, to: "web3#poaps"
          end
        end
      end
    end
  end
  # end Public API

  namespace :external, defaults: {format: :json} do
    resources :persona_webhooks, only: [:create]
  end

  constraints Clearance::Constraints::SignedIn.new { |user| !user.onboarding_complete? } do
    root to: "onboarding#index", as: :onboarding_root
    post "/finish" => "onboarding#finish"

    match "*unmatched", to: redirect("/"), via: :all
  end

  # Business - require log-in
  constraints Clearance::Constraints::SignedIn.new { |user| user.onboarding_complete? } do
    root to: "discovery#index", as: :user_root
    # file uploads
    unless Rails.env.test?
      mount Shrine.uppy_s3_multipart(:cache) => "/s3/multipart"
    end

    # Talent pages & search
    resources :talent, only: [:index]
    # Portfolio
    resource :portfolio, only: [:show]

    # Chat
    resources :messages, only: [:index, :show, :create] do
      post :send_to_all_supporters, on: :collection
      get :send_to_all_supporters_status, on: :collection
    end

    mount ActionCable.server => "/cable"

    # Rewards
    get "earn", to: "rewards#index"

    # Feed
    resources :posts, only: [:show, :create, :destroy] do
      resources :comments, only: [:index, :create, :destroy], module: "posts"
    end

    resources :profiles, only: [:show], param: :username

    # Edit profile
    get "/u/:username/edit_profile", to: redirect("/u/%{username}/account_settings")

    # Quests
    resources :quests, only: [:show]

    namespace :api, defaults: {format: :json} do
      namespace :v1 do
        resources :tokens, only: [:show]
        resources :users, only: [:index, :update] do
          resources :delete_account_tokens, module: "users", only: [:create]

          namespace :profile do
            resources :web3, controller: :web3, only: [:update]

            scope :web3 do
              post :refresh_tokens, to: "web3#refresh_tokens"
              post :refresh_nfts, to: "web3#refresh_nfts"
              post :refresh_poaps, to: "web3#refresh_poaps"
            end
          end
        end

        resources :follows, only: [:index, :create]
        delete "follows", to: "follows#destroy"
        resources :notifications, only: [:index] do
          put :mark_as_read
        end
        post "clear_notifications", to: "notifications#mark_all_as_read"

        resources :career_goals, only: [] do
          resources :goals, only: [:update, :create, :destroy], module: "career_goals"
        end
        resources :talent, only: [:index, :update] do
          resources :milestones, only: [:create, :update, :destroy], module: "talent"
          resources :perks, only: [:create, :update, :destroy], module: "talent"
          resources :tokens, only: [:update], module: "talent"
          resources :career_goals, only: [:update, :create], module: "talent"
        end
        resources :stakes, only: [:create]
        post "reward_claiming", to: "stakes#reward_claiming"
        resources :perks, only: [:show]
        resources :races, only: [:show]
        resources :impersonations, only: [:create, :destroy]
        resources :tags, only: [:index]
        resource :with_persona_requests, only: [:update]
      end
    end
  end

  # Public routes

  resources :discovery, only: [:show], param: :slug

  # Auth - Clearance generated routes

  resources :passwords, controller: "passwords", only: [:create, :new]
  resource :session, controller: "sessions", only: [:create]

  resources :users, only: [:create, :index] do
    post :send_confirmation_email
    resource :password,
      controller: "passwords",
      only: [:edit, :update]
  end

  constraints Routes::FormatConstraints.new(:html) do
    get "/join(/:invite_code)" => "pages#home", :as => :sign_up
    get "/" => "sessions#new", :as => "sign_in"
    delete "/" => "sessions#new", :as => "sign_in_redirect"
    get "/confirm_email(/:token)" => "email_confirmations#update", :as => "confirm_email"
    get "/sign_up", to: redirect("/join")
  end

  get "/auth/linkedin/callback", to: "oauth_callbacks#linkedin"
  post "/auth/unstoppable_domains/login", to: "oauth_callbacks#unstoppable_domains"

  delete "/sign_out" => "sessions#destroy", :as => "sign_out"
  # end Auth

  resources :wait_list, only: [:create, :index]

  get "/u/:username/delete_account" => "users#destroy", :as => "delete_account", :constraints => {username: /[^\/]+/}
  get "/u/:username" => "profiles#show", :as => "user", :constraints => {username: /[^\/]+/}
  get "/u/:username/account_settings" => "users#edit_profile", :as => "account_settings", :constraints => {username: /[^\/]+/}
  # redirect /talent to /u so we have the old route still working
  get "/talent/:username", to: redirect("/u/%{username}"), as: "talent_profile"

  constraints Routes::FormatConstraints.new(:html) do
    root to: "sessions#new", as: :root
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  match "*unmatched", to: "application#route_not_found", via: :all
end

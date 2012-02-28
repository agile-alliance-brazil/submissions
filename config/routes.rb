# encoding: UTF-8
AgileBrazil::Application.routes.draw do
  root :to => 'static_pages#show', :page => 'home'

  devise_for :users,
             :controllers => {
               :sessions      => "user_sessions",
               :registrations => "registrations",
               :passwords     => "password_resets"
             },
             :path_names => {
               :sign_in       => 'login',
               :sign_out      => 'logout',
               :sign_up       => 'signup'
             }

  resources :users, :only => [:index, :show] do
    match 'my_sessions' => 'sessions#index', :as => :my_sessions
  end
  
  resources :tags, :only => [:index]

  scope "(:year)", :constraints => { :year => /\d{4}/ } do
    resources :audience_levels, :only => [:index]
    resources :organizers, :except => [:show]
    resources :organizer_sessions, :only => [:index]
    resources :review_decisions, :only => [:index]
    resources :reviewers, :only => [:index, :new, :create, :destroy, :update] do
      resource :accept, :only => [:show], :controller => :accept_reviewers
      resource :reject, :only => [:show, :update], :controller => :reject_reviewers
    end

    resources :reviewer_sessions, :only => [:index]
    resources :sessions, :except => [:destroy] do
      member do
        delete :cancel
      end
      resources :comments, :except => [:new]
      resources :reviews, :except => [:edit, :update, :destroy] do
        collection do
          get :organizer
        end
      end
      resources :review_decisions, :only => [:new, :create, :edit, :update]
      resource :confirm, :only => [:show, :update], :controller => :confirm_sessions
      resource :withdraw, :only => [:show, :update], :controller => :withdraw_sessions
    end

    resources :accepted_sessions, :only => [:index]
    resources :reviews, :only => [:index], :controller => :reviews_listing do
      collection do
        get :reviewer
      end
    end

    resources :session_types, :only => [:index]
    resources :tracks, :only => [:index]

    match ':page' => 'static_pages#show', :as => :static_page, :page => /home|guidelines|syntax_help/
  end
end

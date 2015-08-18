# encoding: UTF-8
AgileBrazil::Application.routes.draw do
  use_doorkeeper

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1 do
      resource :user, only: [:show] do
        post :make_voter, on: :collection
      end
      resources :sessions, only: [:show]
      scope "(:year)", constraints: { year: /\d{4}/ } do
        resources :sessions, only: [] do
          collection do
            get :accepted
          end
        end
      end
      resources :top_commenters, only: [:index]
    end
  end

  devise_for :users,
             controllers: {
               sessions: "user_sessions",
               registrations: "registrations",
               passwords: "password_resets"
             },
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               sign_up: 'signup'
             }

  resources :users, only: [:index, :show]
  resources :tags, only: [:index]

  scope "(:year)", constraints: { year: /\d{4}/ } do
    root to: 'static_pages#show', page: 'home'

    resources :audience_levels, only: [:index]
    resources :organizers, except: [:show]
    resources :organizer_sessions, only: [:index]
    resources :organizer_reports, only: [:index]
    resources :accepted_sessions, only: [:index]
    resources :review_decisions, only: [:index]
    resources :reviewers, only: [:index, :show, :create, :destroy] do
      collection do
        post :create_multiple
      end
      resource :accept, only: [:show, :update], controller: :accept_reviewers
      resource :reject, only: [:show, :update], controller: :reject_reviewers
    end

    resources :reviewer_sessions, only: [:index]
    resources :sessions, except: [:destroy] do
      member do
        delete :cancel
      end
      resources :comments, except: [:new]
      resources :reviews, except: [:edit, :update, :destroy] do
        collection do
          get :organizer
        end
      end
      resources :review_decisions, only: [:new, :create, :edit, :update]
      resource :confirm, only: [:show, :update], controller: :confirm_sessions
      resource :withdraw, only: [:show, :update], controller: :withdraw_sessions
    end
    resources :users, except: [:index, :show, :new, :create, :update, :edit, :destroy] do
      resources :sessions, only: [:index]
    end

    resources :reviews, only: [:index], controller: :reviews_listing do
      collection do
        get :reviewer
      end
    end

    resources :session_types, only: [:index]
    resources :tracks, only: [:index]

    resources :votes, only: [:index, :create, :destroy]
    resources :review_feedbacks, only: [:new, :create, :show]

    get ':page' => 'static_pages#show', as: :static_page, page: /home|guidelines|syntax_help|call_for_reviewers/
  end
end

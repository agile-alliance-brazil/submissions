# encoding: UTF-8
AgileBrazil::Application.routes.draw do
  use_doorkeeper

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1 do
      resource :user, only: %i(show) do
        post :make_voter, on: :collection
      end
      resources :sessions, only: %i(show)
      scope '(:year)', constraints: { year: /\d{4}/ } do
        resources :sessions, only: %i(index) do
          collection do
            get :accepted
          end
        end
      end
      resources :top_commenters, only: %i(index)
    end
  end

  devise_for :users,
             controllers: {
               sessions: 'user_sessions',
               registrations: 'registrations',
               passwords: 'password_resets'
             },
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               sign_up: 'signup'
             }

  resources :conferences, except: %i(show destroy)
  resources :users, only: %i(index show)
  resources :tags, only: %i(index)

  scope '(:year)', constraints: { year: /\d{4}/ } do
    root to: 'pages#show', as: :conference_root

    resources :organizers, except: %i(show)
    resources :organizer_sessions, only: %i(index)
    resources :organizer_reports, only: %i(index)
    resources :accepted_sessions, only: %i(index)
    resources :review_decisions, only: %i(index)
    resources :reviewers, only: %i(index show create destroy) do
      collection do
        post :create_multiple
      end
      resource :accept, only: %i(show update), controller: :accept_reviewers
      resource :reject, only: %i(show update), controller: :reject_reviewers
    end

    resources :reviewer_sessions, only: %i(index)
    resources :sessions, except: %i(destroy) do
      member do
        delete :cancel
      end
      resources :comments, except: %i(new)
      resources :reviews, except: %i(destroy) do
        collection do
          get :organizer
        end
      end
      resources :review_decisions, only: %i(new create edit update)
      resource :confirm, only: %i(show update), controller: :confirm_sessions
      resource :withdraw, only: %i(show update), controller: :withdraw_sessions
    end
    resources :users, except: %i(index show new create update edit destroy) do
      resources :sessions, only: %i(index)
    end

    resources :reviews, only: %i(index), controller: :reviews_listing do
      collection do
        get :reviewer
      end
    end

    resources :audience_levels, only: %i(index create update), as: :conference_audience_levels
    resources :session_types, only: %i(index create update), as: :conference_session_types
    resources :tracks, only: %i(index create update), as: :conference_tracks

    resources :votes, only: %i(index create destroy)
    resources :review_feedbacks, only: %i(new create show)
    resources :pages, except: %i(new edit destroy), as: :conference_pages

    get ':path' => 'pages#show'
    get ':page' => 'static_pages#show', as: :static_page, page: /home|guidelines|syntax_help|call_for_reviewers/
  end
  root to: 'pages#show'
end

ActionController::Routing::Routes.draw do |map|
  map.resources :votes

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.login 'login', :controller => 'user_sessions', :action => 'new'

  map.resources :audience_levels, :only => [:index]
  map.resources :organizers, :except => [:show]
  map.resources :organizer_sessions, :only => [:index]
  map.resources :password_resets, :except => [:destroy]
  map.resources :reviewers, :only => [:index, :new, :create, :destroy, :update] do |reviewer|
    reviewer.resource :accept, :only => [:show], :controller => :accept_reviewers
    reviewer.resource :reject, :only => [:show, :update], :controller => :reject_reviewers
  end
  map.resources :reviewer_sessions, :only => [:index]
  map.resources :sessions, :except => [:destroy], :member => {:cancel => :delete} do |session|
    session.resources :comments, :except => [:new]
    session.resources :reviews, :except => [:edit, :update, :destroy], :collection => {:organizer => :get}
    session.resources :review_decisions, :only => [:new, :create, :edit, :update]
    session.resource  :confirm, :only => [:show, :update], :controller => :confirm_sessions
    session.resource  :withdraw, :only => [:show, :update], :controller => :withdraw_sessions
  end
  map.resources :accepted_sessions, :only => [:index]
  
  map.resources :reviews, :controller => :reviews_listing, :only => [:index], :collection => {:reviewer => :get}
  map.resources :session_types, :only => [:index]
  map.resources :tags, :only => [:index]
  map.resources :tracks, :only => [:index]
  map.resources :user_sessions, :only => [:new, :create, :destroy]
  map.resources :users, :except => [:destroy] do |user|
    user.my_sessions 'my_sessions', :controller => 'sessions', :action => 'index'
  end

  map.static_page ':page', :controller => 'static_pages', :action => 'show', :page => /guidelines|syntax_help/  
  map.root :controller => 'user_sessions', :action => 'new'
end

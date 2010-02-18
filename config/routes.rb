ActionController::Routing::Routes.draw do |map|
  map.resources :votes

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.login 'login', :controller => 'user_sessions', :action => 'new'

  map.resources :audience_levels, :only => [:index]
  map.resources :password_resets, :except => [:destroy]
  map.resources :sessions, :except => [:destroy] do |session|
    session.resources :comments, :except => [:new]
  end
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

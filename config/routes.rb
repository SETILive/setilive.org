Marv::Application.routes.draw do

 
  resources :classifications
  resources :ZooniverseUsers do
    member do 
      post 'badges'
      post 'favourites'
    end
  end
  resources :sources
  resources :subjects


  resources :workflows 
  resources :favourites 
  resources :badges 
  
  match '/classify'  => 'classifications#classify'
  match '/next_subject' => 'subjects#next_subject_for_user'
  match '/current_user' => "ZooniverseUsers#current_logged_in_user"
  match '/about'  => 'about#index'


  match '*all' => 'application#cor', :constraints => {:method => 'OPTIONS'}

  root :to => 'home#index'
  match '/login'   => 'accounts#login', :as => 'login'
  match '/logout'  => 'accounts#logout', :as => 'logout'
  match '/signup'  => 'accounts#signup', :as => 'signup'
  match '/profile' => 'ZooniverseUsers#show', :as => 'profile'
  match '/awardBadge' => 'ZooniverseUsers#awardBadge', :as => 'awardBadge'
  match '/science_report' => 'ZooniverseUsers#index'
end

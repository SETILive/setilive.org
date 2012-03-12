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
  match '/video_tutorial'  => 'about#video_tutorial'


  match '/active_workflow' => 'workflows#active_workflow'

  match '*all' => 'application#cor', :constraints => {:method => 'OPTIONS'}

  match '/user_favourites' => 'ZooniverseUsers#favourites'
  match '/user_recents' => 'ZooniverseUsers#recents'


  match '/login'   => 'accounts#login', :as => 'login'
  match '/logout'  => 'accounts#logout', :as => 'logout'
  match '/signup'  => 'accounts#signup', :as => 'signup'
  match '/sweeps'  => 'accounts#sweeps', :as => 'sweeps'
  match '/sweeps_submit' => 'accounts#sweeps_submit', :as => 'sweeps_submit'

  match '/profile' => 'ZooniverseUsers#show', :as => 'profile'
  match '/awardBadge' => 'ZooniverseUsers#awardBadge', :as => 'awardBadge'
  match '/register_talk_click' => 'ZooniverseUsers#register_talk_click', :as => 'register_talk_click'

  match '/tutorial_subject' => 'subjects#tutorial_subject'

  match '/science_report' => 'ZooniverseUsers#index'
  match '/stats' => 'home#stats'
  match '/telescope_status' => 'home#telescope_status'
  match '/tutorial'  => 'classifications#tutorial'

  match '/recent_classifications'  => 'classifications#recent'

  match '/seen_tutorial' => 'ZooniverseUsers#seen_tutorial'
  match '/team' => 'home#team'
  match '/ted' => 'home#ted'


  match '/sweeps_change' => 'ZooniverseUsers#sweeps_change'
  match '/sweeps_opt_out' => 'ZooniverseUsers#sweeps_out'

  match '/gallery' => 'home#gallery'

  root :to => 'home#index'
end

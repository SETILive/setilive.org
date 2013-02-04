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
  resources :results

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  
  match '/classify'  => redirect('/#/classify') #'classifications#classify'
  match '/next_subject' => 'subjects#next_subject_for_user'
  match '/current_user' => "ZooniverseUsers#current_logged_in_user"

  match '/fake_followup_2' => 'subjects#fake_followup_trigger_2'
  match '/active_workflow' => 'workflows#active_workflow'

  match '*all' => 'application#cor', :constraints => {:method => 'OPTIONS'}

  match '/user_favourites' => 'ZooniverseUsers#favourites'
  match '/user_recents' => 'ZooniverseUsers#recents'
  match '/user_live_stats' => 'ZooniverseUsers#live_classification_stats'

  match '/redirect' => 'accounts#go_home'
  match '/login'   => 'accounts#login', :as => 'login'
  match '/logout'  => 'accounts#logout', :as => 'logout'
  match '/signup'  => 'accounts#signup', :as => 'signup'
  match '/sweeps'  => 'accounts#sweeps', :as => 'sweeps'
  match '/sweeps_submit' => 'accounts#sweeps_submit', :as => 'sweeps_submit'

  match '/profile' => 'ZooniverseUsers#show', :as => 'profile'
  match '/awardBadge' => 'ZooniverseUsers#awardBadge', :as => 'awardBadge'
  #match '/register_talk_click' => 'ZooniverseUsers#register_talk_click', :as => 'register_talk_click'

  match '/tutorial'  => redirect('/#/classify/tutorial') #'classifications#tutorial'
  match '/video_tutorial' => redirect('/#/about/video_tutorial')
  match '/about' => redirect('/#/about')
  match '/ted' => redirect('/#/about/ted')
  match '/team' => redirect('/#/about/team')
  match '/tutorial_subject' => 'subjects#tutorial_subject'
  match '/seen_tutorial' => 'ZooniverseUsers#seen_tutorial'
  match '/seen_marking_notice' => 'ZooniverseUsers#seen_marking_notice'

  match '/science_report' => 'ZooniverseUsers#index'
  match '/stats' => 'home#stats'
  match '/telescope_status' => 'home#telescope_status'
  match '/telescope_status_change_time' => 'home#telescope_status_change_time'
  match '/time_to_followup' => 'home#time_to_followup'
  match '/time_to_new_data' => 'home#time_to_new_data'
  match '/retrieve_system_state' => 'home#retrieve_system_state'

  match '/recent_classifications'  => 'classifications#recent'

  match '/sweeps_change' => 'ZooniverseUsers#sweeps_change'
  match '/sweeps_opt_out' => 'ZooniverseUsers#sweeps_out'
  match '/telescope_toggle_notify' => 'ZooniverseUsers#telescope_toggle_notify'
  match '/telescope_notify_users' => 'ZooniverseUsers#telescope_notify_users'

  match '/gallery' => redirect('/#/about/gallery') #'home#gallery'
  match '/simulations' => 'home#simulations'

  root :to => 'home#index'
end

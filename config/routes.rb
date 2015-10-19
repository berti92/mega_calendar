# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get '/calendar', :to => 'calendar#index'
get '/calendar/index', :to => 'calendar#index'
get '/calendar/get_events', :to => 'calendar#get_events'
get '/holidays/new', :to => 'holidays#new'
get '/holidays/create', :to => 'holidays#create'
get '/holidays/show', :to => 'holidays#show'
get '/holidays/edit', :to => 'holidays#edit'
get '/holidays/update', :to => 'holidays#update'
get '/holidays/destroy', :to => 'holidays#destroy'
get '/holidays', :to => 'holidays#index'
get '/holidays/index', :to => 'holidays#index'

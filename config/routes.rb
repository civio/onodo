Rails.application.routes.draw do

  root 'home#index'

  devise_for :users, :skip => [:sessions], controllers: { registrations: 'registrations' }
  devise_scope :user do
    get     'login'    => 'devise/sessions#new',      as: :new_user_session
    post    'login'    => 'devise/sessions#create',   as: :user_session
    delete  'logout'   => 'devise/sessions#destroy',  as: :destroy_user_session
    get     'settings' => 'registrations#edit',       as: :edit_settings
  end
  
  # Add user profile page & dashboard
  scope 'dashboard' do
    get ''               => 'users#show_dashboard',                as: :dashboard
    get 'visualizations' => 'users#show_dashboard_visualizations', as: :visualizations_dashboard
    get 'stories'        => 'users#show_dashboard_stories',        as: :stories_dashboard
  end
  resources :users, :only => [:show] do
    collection do
      get ':id/visualizations' => 'users#show_visualizations', as: :visualizations
      get ':id/stories'        => 'users#show_stories',        as: :stories
    end
  end

  resources :visualizations, :only => [:show, :edit, :new, :create, :update, :destroy] do 
    collection do 
      get  ':id/edit/info' => 'visualizations#editinfo'
      post 'publish'
      post 'unpublish'
    end 
  end 

  resources :stories, :only => [:show, :edit, :new, :create, :update, :destroy] do 
    collection do 
      get  ':id/edit/info' => 'stories#editinfo'
      post 'publish'
      post 'unpublish'
    end 
  end 

  resources :datasets, :only => [:index]

  resources :nodes, :only => [:index, :edit, :update] do
    collection do 
      get ':id/edit/description' => 'nodes#edit_description'
      get ':id/edit/image'       => 'nodes#edit_image'
    end 
  end

  get '/explore'                 => 'pages#explore_stories'
  get '/explore/visualizations/' => 'pages#explore_visualizations'
  get '/explore/stories/'        => 'pages#explore_stories'
  get '/gallery'                 => 'pages#gallery'


  # API routes
  scope 'api', as: :api do
    scope 'visualizations' do
      get ':visualization_id'                 => 'api#visualization',        as: :visualization
      put ':visualization_id'                 => 'api#visualization_update'
      patch ':visualization_id'               => 'api#visualization_update_attr'
      get ':visualization_id/nodes'           => 'api#nodes'
      get ':visualization_id/nodes/types'     => 'api#nodes_types'
      get ':visualization_id/relations'       => 'api#relations'
      get ':visualization_id/relations/types' => 'api#relations_types'
    end
    scope 'nodes' do
      post   ''    => 'api#node_create',      as: :nodes
      get    ':id' => 'api#node',             as: :node
      put    ':id' => 'api#node_update'
      patch  ':id' => 'api#node_update_attr'
      delete ':id' => 'api#node_destroy'
    end
    scope 'relations' do
      post    ''   => 'api#relation_create',  as: :relations
      get    ':id' => 'api#relation',         as: :relation
      put    ':id' => 'api#relation_update'
      delete ':id' => 'api#relation_destroy'
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

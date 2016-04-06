Rails.application.routes.draw do

  # You can have the root of your site routed with "root"
  root 'home#index'

  devise_for :users, :skip => [:sessions], controllers: {registrations: 'registrations'}
  devise_scope :user do
    get 'login' => 'devise/sessions#new', :as => :new_user_session
    post 'login' => 'devise/sessions#create', :as => :user_session
    delete 'logout' => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  
  # Add user profile page & dashboard
  resources :users, :only => [:show]
  get '/users/:id/visualizations' => 'users#show'
  get '/users/:id/stories'        => 'users#show_stories'
  
  resources :visualizations, :only => [:show, :edit, :new, :create, :update, :destroy] do 
    collection do 
      get ':id/edit/info' => 'visualizations#editinfo'
      post 'publish'
      post 'unpublish'
    end 
  end 

  resources :stories, :only => [:show, :edit, :new, :create, :update, :destroy] do 
    collection do 
      get ':id/edit/info' => 'stories#editinfo'
      post 'publish'
      post 'unpublish'
    end 
  end 

  resources :datasets, :only => [:index]

  resources :nodes, :only => [:index, :edit, :update] do
    collection do 
      get ':id/edit/description'  => 'nodes#edit_description'
    end 
  end

  get '/explore'                  => 'pages#explore_stories'
  get '/explore/visualizations/'  => 'pages#explore_visualizations'
  get '/explore/stories/'         => 'pages#explore_stories'
  get '/gallery'                  => 'pages#gallery'


  # API routes
  scope 'api' do
    scope 'visualizations' do
      get     ':dataset_id/nodes'           => 'api#nodes'
      get     ':dataset_id/nodes/types'     => 'api#nodes_types'
      get     ':dataset_id/relations'       => 'api#relations'
      get     ':dataset_id/relations/types' => 'api#relations_types'
    end
    scope 'nodes' do
      post    ''        => 'api#node_create'
      get     ':id'     => 'api#node'
      put     ':id'     => 'api#node_update'
      delete  ':id'     => 'api#node_destroy'
    end
    scope 'relations' do
      post    ''        => 'api#relation_create'
      get     ':id'     => 'api#relation'
      put     ':id'     => 'api#relation_update'
      delete  ':id'     => 'api#relation_destroy'
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

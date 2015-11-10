Rails.application.routes.draw do

  # You can have the root of your site routed with "root"
  root 'home#index'

  resources :visualizations
  resources :datasets
  resources :relations
  resources :nodes

  get '/explore' => 'pages#explore'
  get '/gallery' => 'pages#gallery'

  # API routes
  scope 'api' do
    scope 'visualizations' do
      # Node routes
      get     ':dataset_id/nodes'         => 'api#nodes'
      post    ':dataset_id/nodes'         => 'api#node_create'
      get     ':dataset_id/nodes/:id'     => 'api#node'
      put     ':dataset_id/nodes/:id'     => 'api#node_update'
      delete  ':dataset_id/nodes/:id'     => 'api#node_destroy'
      # Relation routes
      get     ':dataset_id/relations'       => 'api#relations'
      post    ':dataset_id/relations'       => 'api#relation_create'
      get     ':dataset_id/relations/:id'   => 'api#relation'
      put     ':dataset_id/relations/:id'   => 'api#relation_update'
      delete  ':dataset_id/relations/:id'   => 'api#relation_destroy'
    end
    # Nodes Types
    get     '/nodes-types'   => 'api#node_types'
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

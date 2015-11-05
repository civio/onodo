Rails.application.routes.draw do

  resources :datasets
  # You can have the root of your site routed with "root"
  root 'home#index'

  resources :nodes
  resources :relations

  # API routes
  scope 'api' do
    # Node routes
    get     'nodes'       => 'api#nodes'
    post    'nodes'       => 'api#node_create'
    get     'nodes/:id'   => 'api#node'
    put     'nodes/:id'   => 'api#node_update'
    delete  'nodes/:id'   => 'api#node_destroy'
    get     'nodes-types' => 'api#node_types'
    # Relation routes
    get     'relations'       => 'api#relations'
    post    'relations'       => 'api#relation_create'
    get     'relations/:id'   => 'api#relation'
    put     'relations/:id'   => 'api#relation_update'
    delete  'relations/:id'   => 'api#relation_destroy'
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

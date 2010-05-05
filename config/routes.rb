ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.root :controller => 'root'

  map.resource :api, :controller => 'api', :only => [:show]

  #map.connect 'tasks/status/:status.:format', :path_prefix => 'api', :controller => 'tasks', :action => 'index', :conditions => { :method => :get }, :requirements => { :id => /\d+/ }

  map.resources :appliances, :path_prefix => 'api', :except => [:edit, :new], :requirements => {:id => /\d+/}
  map.resources :images, :path_prefix => 'api', :member => {:deliver => :get, :convert => :post}, :except => [:update, :edit, :new], :requirements => {:id => /\d+/}
  #map.resources :packages, :path_prefix => 'api', :except => [:update, :edit, :new], :member => { :download => :get }, :requirements => { :id => /\d+/ }


  #map.connect 'images/:id/package/:image_type/:archive_type.:format', :path_prefix => 'api', :controller => 'images', :action => 'package', :conditions => { :method => :post }, :requirements => { :id => /\d+/ }


  #map.connect 'images/:action/:image_id', :controller => 'images'

  #map.connect 'images/:id', :path_prefix => 'api', :controller => 'definitions', :action => 'show', :requirements => { :id => /\d/ }  

  # requirements
  #map.connect 'definitions/:id', :path_prefix => 'api', :controller => 'definitions', :action => 'show', :requirements => { :id => /\d/ }

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end

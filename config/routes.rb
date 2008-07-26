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
    
  map.resources :tags
  
  map.resources :memberships
  
  map.resources :open_ids
  
  map.with_options :controller => 'open_ids' do |open_ids|
    open_ids.formatted_server 'open_ids.:format', :action => 'index'
    open_ids.server 'open_ids', :action => 'index'
    open_ids.decide 'open_ids/decide', :action => 'decide'
    open_ids.proceed 'open_ids/proceed', :action => 'proceed'
    open_ids.complete 'open_ids/complete', :action => 'complete'
    open_ids.cancel 'open_ids/cancel', :action => 'cancel'
    open_ids.formatted_seatbelt_config 'open_ids/seatbelt/config.:format', :action => 'seatbelt_config'
    open_ids.formatted_seatbelt_state 'open_ids/seatbelt/state.:format', :action => 'seatbelt_login_state'
  end

  map.root :controller => "blogs", :action => "home"

  map.resources :sites, :member => {:set_states => :post}

  map.resources :categories

  # Globalize插件所需路由
  map.connect ':locale/:controller/:action/:id'
  
  map.namespace :admin do |admin|
    admin.resources :translate
  end
  
	map.resources :commenters, :member => { :suspend   => :put,
                                          :unsuspend => :put,
                                          :purge     => :delete }

  map.resources :comments
  map.resources :articles, :has_many => [:replies, :comments, :tags]
  map.resources :blogs, :collection  => { :home => :get }, :has_many => [:articles, :users]

  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  
  map.resource :session
  
  # restful-authentication 所需路由
  map.signup '/signup', :controller => 'users',    :action => 'new'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  
  map.with_options :controller => 'users' do |user|
    user.formatted_identity ':user.:format', :action => 'show'
    user.identity ':user', :action => 'show'
  end

  map.resources :users, :member => { :suspend         => :put, 
                                     :unsuspend       => :put, 
                                     :purge           => :delete, 
                                     :change_password => :put },
                :has_many => [:blogs, :articles, :open_ids, :tags]
  
  map.resource :password
  
  map.with_options :controller => 'passwords' do |pwd|
    pwd.forgot_password 'forgot_password', :action    => 'new'
    pwd.reset_password  'reset_password/:id', :action => 'edit'
  end
  
  map.connect 'open_ids/xrds', :controller       => 'open_ids', :action => 'idp_xrds'
  map.connect 'user/:username', :controller      => 'open_ids', :action => 'user_page'
  map.connect 'user/:username/xrds', :controller => 'open_ids', :action => 'user_xrds'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  # 未知路径让blogs/unkown_request处理,返回404或者其它
  # map.connect "*inputs", :controller => "blogs", :action => "unkown_request" if Rails.env.production?
end

RailsCogname::Application.routes.draw do

  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  root to: 'static_content#home'

  #301 redirect to overrule resource definition
  match "businesses/", to: redirect("search/"), via: :get

  resources :users
  resources :businesses, except: [:index]
  resources :products do
    get :autocomplete_product_type_label, on: :collection
    get :autocomplete_name_object_name, on: :collection
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets
  resources :coupons, only: [:new, :create, :destroy]

  namespace :social do
    resources :golf_courses
    resources :ski_areas
    resources :radio_stations
    resources :candles
  end

  match 'signin/', to: 'sessions#new', via: :get
  match 'signout/', to: 'sessions#destroy', via: :delete
  match 'signup/', to: 'users#new', via: :get
  match 'profile/', to: 'users#show', via: :get
  match 'profile/edit', to: 'users#edit', via: :get

  match 'about/', to: 'static_content#about', via: :get
  match 'contact/', to: "static_content#contact", via: :get
  match 'terms/', to: "static_content#terms", via: :get
  match 'team/', to: "static_content#team", via: :get
  match 'why/', to: "static_content#why", via: :get
  match 'faq/', to: "static_content#faq", via: :get
  match 'actual_use/', to: "static_content#actual_use", via: :get
  match 'construction/', to: "static_content#construction", via: :get
  match 'pricing/', to: "static_content#pricing", via: :get

  match 'admin/user_submitted_business/', to: "businesses#admin_index", via: :get
  match 'search/', to: "businesses#index", via: :get
  match 'businesses/:id/proof', to: "businesses#proof", via: :get
  match 'businesses/:id/full_image', to: "businesses#full_image", via: :get, as: :business_full_image

  match 'businesses/upgrade', to: "businesses#upgrade", via: :post
  match 'businesses/page_errors', to: "businesses#page_errors", via: :post
  match 'businesses/:id/renew', to: "businesses#renew", via: :get, as: :businesses_renew
  match 'businesses/update_expiration', to: "businesses#update_expiration", via: :post

  match 'coupons/email', to: "coupons#email", via: :post
  match 'coupon_check', to: "coupons#coupon_check", via: :post

  match 'products/:id/logo_image', to: "products#logo_image", via: :get, as: :product_logo_image
  match 'products/:id/full_image', to: "products#full_image", via: :get, as: :product_full_image
  match 'products/add_and_continue', to: "products#add_and_continue", via: :post, as: :product_add_and_continue
  match 'products/add_and_checkout', to: "products#add_and_checkout", via: :post, as: :product_add_and_checkout
  match 'products/:id/renew', to: "products#renew", via: :get, as: :products_renew

  match 'checkout', to: "products#checkout", via: :get
  match 'pay_for_cart', to: "products#pay_for_cart", via: :post

  #BlogIt engine
  mount Blogit::Engine => '/blog'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

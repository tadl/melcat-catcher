Ilscatcher::Application.routes.draw do
  get "feedback/staff"

  get "main/index"
  get "main/searchjson"
  get "main/itemdetails"
  get "main/about"
  get "main/hold"
  get "main/multihold"
  get "main/renew"
  get "main/login"
  get "main/showcheckouts"
  get "main/showholds"
  get "main/cancelhold"
  get "main/holdaction"
  get "main/showpickups"
  get "main/itemonshelf"
  get "main/showcard"
  get "main/checkupdates"
  get "melcat/searchmelcat"
  get "melcat/showmelcat"
  get "melcat/testmelcat"
  get "melcat/hold"
  get "main/search_prefs"
  get "main/create_list"
  get "main/add_to_list"
  get "main/get_list"
  get "main/get_token"
  get "main/get_user_with_token"
  get "main/get_user_lists"
  get "main/remove_from_list"
  get "main/marc"
  get "main/receipt_print"
  get "main/receipt_email"
  get "main/passwordreset"
  get "main/get_checkout_history"
  get "main/get_hold_history"
  get "main/get_payment_history"
  get "main/get_fines"
  get "drupal/test"
  get "drupal/drupal"
  get "drupal/library_reads"
  get "drupal/ny_list"  
  root :to => 'main#index'
  
  match ':controller/:action/:pagenumber/:querytitle'
  


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

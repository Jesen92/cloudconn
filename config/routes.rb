Rails.application.routes.draw do


  resources :subscribers
  get 'services/index'

  get 'services/show'

  get 'services/free_trial_request' => "services#free_trial_request", :as => 'free_trial'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  ActiveAdmin.routes(self)
  scope ":locale", locale: /#{I18n.available_locales.join("|")}/ , defaults: {locale: "hr"} do
    resources :services do
      post :calculator, on: :collection
      post :contact_us, on: :collection
      post :subscriber_create, on: :collection
      get :free_trial_request, on: :collection
      get :general_conditions_download, on: :collection
    end
    root 'services#index'
    devise_for :users, controllers: {sessions: 'users/sessions', registrations: 'users/registrations', confirmations: 'users/confirmations', passwords: 'users/passwords'}

  end

  match '*path', to: redirect("/#{I18n.locale}/%{path}"), :via => [:get]
  match '', to: redirect("/#{I18n.locale}"), :via => [:get]
  #match '*/admin', to: redirect("/admin"), :via => [:get]
  #match '*/admin/*path', to: redirect("/admin/%{path}"), :via => [:get]
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

Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions",registrations: 'registrations'  }

  devise_scope :user do
    authenticated :user do
      root 'worksessions#homepage', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  get '/worksessions/create_2_weeks' => 'worksessions#create_worksessions', as: :create_worksessions
  get '/users/reset_password' => 'users#reset_password', as: :reset_password
  resources :users do
      resources :worksessions
  end
  get '/worksessions/available' => 'worksessions#available', as: :available
  resources :worksessions
  
  resources :worksession do
    get :get_events, on: :collection
  end
  post '/worksessions/:id/sign_up' => 'worksessions#sign_up', as: :signup
  get '/worksessions/:id/sign_up' => 'worksessions#sign_up', as: :signUp


  get '/worksessions/:id/cancel' => 'worksessions#cancel', as: :cancel
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

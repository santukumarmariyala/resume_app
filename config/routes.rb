Rails.application.routes.draw do
  devise_for :users
  root :to => 'beautiful#dashboard'
  match ':model_sym/select_fields' => 'beautiful#select_fields', :via => [:get, :post]

  concern :bs_routes do
    collection do
      post :batch
      get  :treeview
      match :search_and_filter, :action => :index, :as => :search, :via => [:get, :post]
    end
    member do
      post :treeview_update
    end
  end

  # Add route with concerns: :bs_routes here # Do not remove
  resources :resumes, concerns: :bs_routes
  

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

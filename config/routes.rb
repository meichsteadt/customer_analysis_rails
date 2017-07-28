Rails.application.routes.draw do
  resources :customers do
    resources :orders
    resources :comparisons
    resources :recommendations
  end
  resources :login
  root to: 'customers#index'
  get 'customers/with_sorting/:sort_by', to: 'customers#index'
  get 'customers/:id/:sort_by', to: 'customers#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

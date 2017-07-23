Rails.application.routes.draw do
  resources :customers do
    resources :orders
  end
  get 'customers/with_sorting/:sort_by', to: 'customers#index'
  get 'customers/:id/:sort_by', to: 'customers#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

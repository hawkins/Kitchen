Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :recipes do
    get 'search_api', on: :collection
    get 'search', on: :collection
  end
end

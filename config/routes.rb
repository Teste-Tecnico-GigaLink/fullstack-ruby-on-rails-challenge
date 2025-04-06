Rails.application.routes.draw do
  resources :dynamics do
    get 'random', on: :collection
    resources :reviews, only: [:create]
  end
  root 'dynamics#index'
end
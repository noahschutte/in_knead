Rails.application.routes.draw do

  resources :users, only: [:show, :create, :update]
  resources :requests, only: [:index, :create, :update, :destroy]
  resources :thank_you, only: [:create, :update, :destroy]
  resources :anon, only: [:show]

end

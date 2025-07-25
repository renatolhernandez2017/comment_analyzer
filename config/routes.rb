require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  root "home#index"

  resources :analyze, only: %i[index create update destroy]

  get "/results/:username", to: "analyze#show", as: :results
  get "/progress/:username", to: "analyze#progress", as: :progress
  get "/results_groups", to: "keywords#show", as: :results_groups

  resources :keywords, only: %i[index create update destroy]
  resources :users
end

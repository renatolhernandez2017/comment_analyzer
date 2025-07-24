require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  root "analyze#index"

  post "/analyze", to: "analyze#create"
  get "/results/:username", to: "analyze#show", as: :results
  get "/progress/:username", to: "analyze#progress", as: :progress
end

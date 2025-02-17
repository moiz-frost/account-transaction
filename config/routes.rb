# frozen_string_literal: true

Rails.application.routes.draw do
  # devise_for :accounts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :accounts do
        member do
          get 'transactions'
          post 'transfer'
        end
      end
    end
  end

  post 'login', to: 'cookie#login'
end

# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :accounts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post 'login', to: 'cookie#login'
    end
  end
end

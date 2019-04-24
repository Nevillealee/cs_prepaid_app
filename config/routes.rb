# frozen_string_literal: true

Rails.application.routes.draw do
  # root 'dashboards#index'
  devise_for :users, controllers: { registrations: 'users/registrations'  }
  resource :customers, only: [:index, :search, :show]

  devise_scope :user do
    authenticated do
      root 'customer#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :root
    end
  end
  resources :users
  namespace :customer do
    resources :orders, only: [:show, :edit, :update]
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  # root 'dashboards#index'
  devise_for :users, controllers: { registrations: 'users/registrations'  }
  resources :customers, only: [:index, :show]
  get 'customer/search', to: 'customers#search'

  devise_scope :user do
    authenticated do
      root 'customers#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :root
    end
  end
  resources :users
  resources :customers do
    resources :orders, only: [:show, :edit, :update]
  end
end

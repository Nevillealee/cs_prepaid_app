# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations'  }
  resources :customers, only: [:index, :show]

  devise_scope :user do
    authenticated do
      root 'customers#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :root
    end
  end

  resources :users
  namespace :customer do
    resources :orders, only: [:index, :show, :edit, :update]
  end
end

# frozen_string_literal: true
require 'resque/server'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations'  }
  resources :customers, only: [:index, :show]
  get 'customer/orders/:id/size_edit', action: :size_edit, controller: 'customer/orders', as: :edit_customer_order_sizes

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
    patch 'orders/size_edit/:id', to: 'orders#size_update', as: :order_sizes
  end

  authenticate :user do
    mount Resque::Server, at: '/jobs'
  end
end

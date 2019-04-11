Rails.application.routes.draw do
  root 'dashboards#index'
  devise_for :users, :controllers => { :registrations => 'users/registrations'  }
  #
  # devise_scope :user do
  #   authenticated do
  #     root 'dashboard#dashboard', as: :authenticated_root
  #   end
  #
  #   unauthenticated do
  #     root 'devise/sessions#new', as: :root
  #   end
  # end
  resources :users
end

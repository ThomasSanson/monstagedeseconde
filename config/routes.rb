Rails.application.routes.draw do

  devise_for :users, controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/choose_profile' => 'users/registrations#choose_profile'
  end

  resources :internship_offers do
    resources :internship_applications, only: [:create, :update, :index]
  end

  namespace :dashboard, path: "dashboard" do
    resources :schools, only: [:edit, :update, :index, :show] do
      resources :users, only: [:destroy, :update, :index], module: 'schools'
      # MAYBE TODO: index
      resources :class_rooms, only: [:new, :create, :edit, :update, :show], module: 'schools' do
        # MAYBE TODO: index
        resources :students, only: [:show, :update], module: 'class_rooms'
      end
    end
  end

  resources :users, only: [:edit, :update]

  get 'account', to: 'users#edit'
  patch 'account', to: 'users#update'

  get 'dashboard', to: 'dashboard#index'

  root to: "pages#home"
end

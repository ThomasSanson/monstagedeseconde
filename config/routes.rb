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
    # DASHBOARD: show
    resources :schools, only: [:edit, :update, :index, :show] do
      # MAYBE TODO: index
      # DASHBOARD: show
      resources :users, only: [:destroy, :update], module: 'schools'
      # MAYBE TODO: index
      resources :class_rooms, only: [:new, :create, :edit, :update, :show], module: 'schools' do
        # MAYBE TODO: index
        resources :students, only: [:show, :update]
      end
    end
  end
  get 'account', to: 'account#show'
  get 'account/edit', to: 'account#edit'
  patch 'account', to: 'account#update'

  root to: "pages#home"
end

Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  resources :courses do
    member do
      post :enroll
      get :manage
      get :certificate
      get :review_student
    end
    resources :chapters, except: [ :index, :show ]
  end

  resources :chapters, only: [] do
    resources :quizzes, only: [ :new, :create, :edit, :update, :destroy ]
  end

  resources :quizzes, only: [] do
    resource :answer, only: [ :create, :update ]
  end

  resources :answers, only: [] do
    member do
      patch :review
    end
  end

  namespace :admin do
    resources :users, only: [ :index ] do
      member do
        patch :update_role
        post :reset_password
      end
    end
  end

  get "my_courses", to: "courses#mine", as: :my_courses

  root "courses#index"
end

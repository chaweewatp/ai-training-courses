Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  resources :courses do
    member do
      post :enroll
      get :manage
      get :certificate
      get :review_student
      get :pre_test
      get :post_test
      post :submit_test
      patch :toggle_publish
    end
    resources :chapters, except: [ :index, :show ] do
      member do
        patch :toggle_publish
      end
    end
    resources :test_questions
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
    resources :skills, except: [ :show ]
  end

  get "my_skills", to: "skills#index", as: :my_skills

  patch "my_name", to: "skills#update_name", as: :my_name

  get "my_courses", to: "courses#mine", as: :my_courses

  get "my_certificates", to: "certificates#index", as: :my_certificates

  root "courses#index"
end

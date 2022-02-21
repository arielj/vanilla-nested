Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :users do
    collection do
      get :new_with_custom_link_tag
      get :new_with_undo
      get :new_with_attributes_on_link_tag
      get :new_using_turbo
    end
  end
end

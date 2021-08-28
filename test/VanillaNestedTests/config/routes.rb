Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    collection do
      get :new_with_custom_link_tag
      get :new_with_undo
    end
  end
end

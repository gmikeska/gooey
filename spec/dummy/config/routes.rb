Rails.application.routes.draw do
  resources "pages"
  scope module: 'gooey' do
    resources :designs
    resources :components
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

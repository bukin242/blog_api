Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :public_api, defaults: {format: 'json'} do
    post :posts, to: 'posts#create'
    get :posts, to: 'posts#rating_top'
    put :posts, to: 'posts#rating_update'
    get 'posts/ips_different_authors', to: 'posts#ips_different_authors'
  end
end

resources :article_categories, :as => article_categories_path
resources :articles, :as => article_path, :member => { :comment => :post }, :has_many => :images

namespace :admin do |admin|
  admin.resources :feeds, :collection => { :create_article => :put }
  admin.resources :article_categories, :has_many => { :features, :menus } do |article_category|
    article_category.resources :menus
    article_category.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put, :add_multiple => :get }
  end
  admin.resources :articles, :has_many => [ :comments, :features, :assets ], :member => { :reorder => :put, :post_preview => :put }, :collection => { :preview => :get, :post_preview => :put } do |article|
    # member do
    #   get :post_preview
    # end
    article.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put, :add_multiple => :get }
  end
end

blog blog_path, :controller => 'articles'

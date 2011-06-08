resources :article_categories, :as => article_categories_path
resources :articles, :as => article_path, :member => { :comment => :post }, :has_many => :images

namespace :admin do |admin|
  admin.resources :article_categories, :has_many => { :features, :menus } do |article_category|
    article_category.resources :menus
    article_category.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put }
  end
  admin.resources :articles, :has_many => [ :comments, :features, :assets ], :member => { :reorder => :put } do |article|
    article.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put, :add_multiple => :get }
  end
end

blog blog_path, :controller => 'articles'

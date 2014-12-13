class AddIndexToArticlesAndArticleCategories < ActiveRecord::Migration
  def self.up
    add_index :articles, :article_category_id, :name => 'index_article_category_id'
  end

  def self.down
    remove_index :articles, :article_category_id
  end
end

class AddIndexToArticleOnArticleCategoryHabtm < ActiveRecord::Migration
  def self.up
  	add_index :article_categories_articles, [:article_id, :article_category_id], :unique => true
	add_index :article_categories_articles, :article_category_id
  end

  def self.down
  	remove_index :article_categories_articles, [:article_id, :article_category_id]
	remove_index :article_categories_articles, :article_category_id
  end
end

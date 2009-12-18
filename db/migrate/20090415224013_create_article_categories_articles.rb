class CreateArticleCategoriesArticles < ActiveRecord::Migration
  def self.up
    create_table :article_categories_articles, :id => false do |t|
      t.integer :article_id, :article_category_id
    end
  end

  def self.down
    drop_table :article_categories_articles
  end
end

class AddColumnIdToArticleCategories < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :column_id, :integer, :default => 2
    add_column :articles, :column_id, :integer, :default => 2
  end

  def self.down
    remove_column :article_categories, :column_id
    remove_column :articles, :column_id
  end
end

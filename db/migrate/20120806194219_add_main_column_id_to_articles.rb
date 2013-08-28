class AddMainColumnIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :main_column_id, :integer
  end

  def self.down
    remove_column :article_categories, :main_column_id
  end
end
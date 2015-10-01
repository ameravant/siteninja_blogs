class AddArticleCategoryIndexToArticles < ActiveRecord::Migration
  def self.up
  	add_index :articles, :person_id
  	add_index :articles, :column_id
  end

  def self.down
  	remove_index :articles, :person_id
  	remove_index :articles, :column_id
  end
end

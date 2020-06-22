class AddDisplayAuthorDateTimeAndCategoriesToArticles < ActiveRecord::Migration
  def self.up
  	add_column :articles, :display_author, :boolean, :default => true
  	add_column :articles, :display_date, :boolean, :default => true
  	add_column :articles, :display_time, :boolean, :default => true
  	add_column :articles, :display_categories, :boolean, :default => true
  end

  def self.down
  	remove_column :articles, :display_author
  	remove_column :articles, :display_date
  	remove_column :articles, :display_time
  	remove_column :articles, :display_categories
  end
end

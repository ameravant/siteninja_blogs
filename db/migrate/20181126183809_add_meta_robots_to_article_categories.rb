class AddMetaRobotsToArticleCategories < ActiveRecord::Migration
  def self.up
  	add_column :article_categories, :meta_robots, :string
  end

  def self.down
  	remove_column :article_categories, :meta_robots
  end
end

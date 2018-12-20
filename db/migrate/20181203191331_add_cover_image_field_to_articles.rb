class AddCoverImageFieldToArticles < ActiveRecord::Migration
  def self.up
  	add_column :articles, :display_cover_image, :boolean, :default => true
  end

  def self.down
  	remove_column :articles, :display_cover_image
  end
end

class AddShowDescriptionToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :show_description, :boolean, :default => false
  end

  def self.down
    remove_column :articles, :show_description
  end
end

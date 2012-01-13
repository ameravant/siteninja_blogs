class AddImportantToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :importance, :string, :default => "Medium"
  end

  def self.down
    remove_column :articles, :importance
  end
end
class AssestCounterToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :assets_count, :integer, :default => 0
  end

  def self.down
    remove_column :articles, :assets_count
  end
end

class AddPublishImmediatelyToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :publish_immediately, :boolean, :default => false
  end

  def self.down
    remove_column :articles, :publish_immediately
  end
end
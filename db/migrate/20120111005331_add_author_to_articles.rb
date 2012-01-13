class AddAuthorToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :author_name, :string
    add_column :articles, :source_url, :string
    add_column :articles, :feed_id, :integer
  end

  def self.down
    remove_column :articles, :feed_id
    remove_column :articles, :source_url
    remove_column :articles, :author_name
  end
end
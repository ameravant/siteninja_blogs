class AddPermissionLevelToArticleCategories < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :permission_level, :string, :default => "everyone"
  end

  def self.down
    remove_column :article_categories, :column_name
  end
end
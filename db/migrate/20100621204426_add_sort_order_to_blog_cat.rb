class AddSortOrderToBlogCat < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :sort_order, :integer
  end

  def self.down
    remove_column :article_categories, :sort_order
  end
end

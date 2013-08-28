class CreateArticleCategoriesPersonGroups < ActiveRecord::Migration
  def self.up
    create_table :article_categories_person_groups, :id => false do |t|
      t.integer :person_group_id
      t.integer :article_category_id
    end
  end

  def self.down
    drop_table :article_categories_person_groups
  end
end

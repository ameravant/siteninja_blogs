class AddNotesToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :notes, :text
  end

  def self.down
    remove_column :articles, :notes
  end
end

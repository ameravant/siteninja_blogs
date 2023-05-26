class AddRenderedBodyToBlog < ActiveRecord::Migration
  def self.up
  	add_column :articles, :rendered_body, :text
  end

  def self.down
  	remove_column :rendered_body
  end
end

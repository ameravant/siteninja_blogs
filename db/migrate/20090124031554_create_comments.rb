class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :name, :email
      t.text :comment
      t.integer :article_id, :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end

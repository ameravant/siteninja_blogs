class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title, :permalink, :description
      t.text :blurb, :body
      t.integer :user_id
      t.integer :comments_count, :images_count, :features_count, :default => 0
      t.datetime :published_at
      t.boolean :notify_author_of_comments, :published, :social_share, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end

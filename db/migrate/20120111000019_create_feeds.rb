class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.string :title, :url, :description
      t.integer :person_id, :article_category_id
      t.integer :results_limit, :default => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end

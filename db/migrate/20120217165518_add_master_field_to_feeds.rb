class AddMasterFieldToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :master, :boolean, :default => false
  end

  def self.down
    remove_column :feeds, :master
  end
end
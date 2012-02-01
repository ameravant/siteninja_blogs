class AddAccountIdToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :account_id, :integer
  end

  def self.down
    remove_column :feeds, :account_id
  end
end
class AddBeRubyFlagToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :beruby_visited, :integer, :default => 0
  end

  def self.down
    remove_column :users, :beruby_visited
  end
end

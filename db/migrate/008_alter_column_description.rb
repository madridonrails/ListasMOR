class AlterColumnDescription < ActiveRecord::Migration
  def self.up    
    change_column :tasks, :description, :string, :null=>true
  end

  def self.down
    change_column :tasks, :description, :string, :null=>false
  end
end

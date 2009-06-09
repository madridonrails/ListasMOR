class HashCodes < ActiveRecord::Migration
  
  def self.up
    add_column :task_lists, :token, :string
    add_column :task_list_users, :token, :string
    add_column :task_list_users, :email, :string
  end  
  
  def self.down
    remove_column  :task_list_users, :email
    remove_column  :task_list_users, :token
    remove_column  :task_lists, :token
  end
  
end
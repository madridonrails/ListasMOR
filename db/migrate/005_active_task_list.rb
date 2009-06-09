class ActiveTaskList < ActiveRecord::Migration
  
  def self.up
    add_column :users, :active_task_list_1_id, :integer, :references=>:task_lists    
    add_column :users, :active_task_list_2_id, :integer, :references=>:task_lists
    add_column :users, :active_task_list_3_id, :integer, :references=>:task_lists
    add_column :users, :active_task_list_4_id, :integer, :references=>:task_lists
  end  
  
  def self.down
    remove_column  :users, :active_task_list_4_id
    remove_column  :users, :active_task_list_3_id
    remove_column  :users, :active_task_list_2_id
    remove_column  :users, :active_task_list_1_id  
  end
  
end
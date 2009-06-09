class UsersAndTasks < ActiveRecord::Migration
  
  def self.up    
    create_table :users do |t|
      # personal data
      t.column :first_name,             :string
      t.column :first_name_for_sorting, :string
      t.column :last_name,              :string
      t.column :last_name_for_sorting,  :string
      t.column :language,  :string, :default=>LocalText.default_language.to_s

      # authentication
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :is_admin, :integer, :default=>0

      
      # timestamps
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    create_table :task_lists do |t|
      t.column :user_id, :integer, :null=>false
      
      t.column :name, :string, :null=>false
      t.column :description, :string
      t.column :closed, :integer, :default=>0
      t.column :public, :integer, :default=>0
      
      t.column :cached_tag_list, :text
      # timestamps
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
        #public, participants,tasks,taggable     
    end
    
    create_table :tasks do |t|
      t.column :task_list_id, :integer, :null=>false
      t.column :user_id, :integer, :null=>true
      
      t.column :name, :string, :null=>false
      t.column :description, :string, :null=>false
      t.column :position, :integer
      t.column :priority, :integer
      t.column :closed, :integer, :default=>0
      t.column :starts_at, :datetime
      t.column :ends_at, :datetime
      
      
      t.column :cached_tag_list, :text
      
      # timestamps
      t.column :created_at, :datetime
      t.column :updated_at, :datetime            
    end
    
    create_table :task_list_users do |t|
      t.column :task_list_id, :integer, :null=>false
      t.column :user_id, :integer, :null=>true
      t.column :read_only, :integer, :default=>1
      # timestamps
      t.column :created_at, :datetime
      t.column :updated_at, :datetime  
    end
  end
  
  def self.down
    drop_table :task_list_users
    drop_table :tasks
    drop_table :task_lists    
    drop_table :users
  end
  
end
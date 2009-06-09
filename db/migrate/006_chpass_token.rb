class ChpassToken < ActiveRecord::Migration
  
  def self.up
    add_column :users, :chpass_token, :string    
  end  
  
  def self.down
    remove_column  :users, :chpass_token
  end
  
end
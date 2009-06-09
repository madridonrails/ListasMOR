class Task < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user    
  belongs_to :task_list  
  acts_as_list :scope => :task_list
  
  #XXX validate user_id is allowed  
  
end

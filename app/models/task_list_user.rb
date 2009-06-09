class TaskListUser < ActiveRecord::Base
  belongs_to :task_list
  belongs_to :user
  
  before_save :assign_token
  
  def assign_token(force=false)
    return if self.token unless force
    
    loop do
      token=ProjectUtils.random_token
      token_exists=TaskListUser.find_by_token(token)
      self.token = token and break unless token_exists
    end
  end
  
end

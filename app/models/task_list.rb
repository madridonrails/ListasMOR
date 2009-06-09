class TaskList < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  has_many :tasks, :order=>"position", :dependent=>:destroy
  has_many :task_list_users, :dependent=>:destroy
  has_many :allowed_users, :through => :task_list_users, :source=>:user
  has_many :active_users_1, :class_name=>'User', :foreign_key => :active_task_list_1_id,:dependent=>:nullify
  has_many :active_users_2, :class_name=>'User', :foreign_key => :active_task_list_2_id,:dependent=>:nullify
  has_many :active_users_3, :class_name=>'User', :foreign_key => :active_task_list_3_id,:dependent=>:nullify
  has_many :active_users_4, :class_name=>'User', :foreign_key => :active_task_list_4_id,:dependent=>:nullify

  before_save :assign_token
  
  def assign_token(force=false)
    return if self.token unless force
    
    loop do
      token=ProjectUtils.random_token
      token_exists=TaskList.find_by_token(token)
      self.token = token and break unless token_exists
    end
  end

  def separate_tasks
    tasks.partition {|t| t.closed?}
  end
  
end

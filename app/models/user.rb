require 'digest/sha1'
class User < ActiveRecord::Base 
  has_many :task_lists, :dependent=>:destroy
  has_many :tasks, :dependent=>:destroy
  has_many :task_list_users, :dependent=>:destroy
  has_many :allowed_task_lists, :through => :task_list_users, :source=>:task_list, :dependent=>:destroy
  belongs_to  :active_task_list_1, :class_name=>'TaskList', :foreign_key => :active_task_list_1_id
  belongs_to  :active_task_list_2, :class_name=>'TaskList', :foreign_key => :active_task_list_2_id
  belongs_to  :active_task_list_3, :class_name=>'TaskList', :foreign_key => :active_task_list_3_id
  belongs_to  :active_task_list_4, :class_name=>'TaskList', :foreign_key => :active_task_list_4_id
  
  add_for_sorting_to :first_name, :last_name

  #### ----------------------------------------- ####
  ##                                               ##
  #                                                 #
  #     acts_as_authenticated stuff follows         #
  #                                                 #
  ##                                               ##
  #### ----------------------------------------- ####
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :email
  validates_presence_of     :email_confirmation
  validates_confirmation_of :email
  validates_uniqueness_of   :email

  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?

  before_save :encrypt_password
  after_create :send_activation_email
  
  def active_list?(the_list)
    list_id=the_list.is_a?(ActiveRecord::Base) ? the_list.id : the_list.to_i
    if active_task_list_1_id==list_id 
      return 1
    elsif active_task_list_2_id==list_id
      return 2
    elsif active_task_list_3_id==list_id
      return 3
    elsif active_task_list_4_id==list_id
      return 4
    else 
      return nil
    end    
  end
  
  def set_active_list(the_list)    
    the_list=the_list.is_a?(ActiveRecord::Base) ? the_list.id : the_list.to_i
    
    return if active_list?(the_list)
      
    self.active_task_list_4_id = active_task_list_3_id unless (active_task_list_3.nil? || active_task_list_3_id == the_list)
    self.active_task_list_3_id = active_task_list_2_id unless (active_task_list_2.nil?  || active_task_list_2_id == the_list)
    self.active_task_list_2_id = active_task_list_1_id unless (active_task_list_1.nil?  || active_task_list_1_id == the_list)
    
    self.active_task_list_1_id = the_list
    self.save  
  end
  
  def deactivate_list(the_list)    
    the_list=the_list.is_a?(ActiveRecord::Base) ? the_list.id : the_list.to_i
    
    active_list_ix=active_list?(the_list)
    unless active_list_ix.nil?
      self.send("active_task_list_#{active_list_ix}=",nil)
      self.save
    end    
  end
  
  def separate_task_lists
    task_lists.partition {|l| l.closed?}
  end

  def separate_allowed_task_lists
    allowed_task_lists.partition {|l| l.closed?}
  end

  def is_anonymous?
    email.blank?
  end
  
  def send_activation_email
      UserNotifier.deliver_activation(self) unless is_anonymous?
  end
  
  def fullname
    [first_name, last_name].reject { |x| x.blank? }.join(' ')
  end
  
  def after_find
    self.email_confirmation = email
  end

  def create_default_task_list
    return if is_anonymous?
    task_list_name=LocalText.text(self.language,:task_list,:default_task_list_name,self.fullname)
    task_list_description=LocalText.text(self.language,:task_list,:default_task_list_description)
    TaskList.new(:name=>task_list_name,:description=>task_list_description,:user_id=>self.id).save!  
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me(anonymous=false)
    self.remember_token_expires_at = 4.weeks.from_now.utc
    
    loop do
      self.remember_token            = encrypt("#{anonymous ? ProjectUtils.random_token : email}--#{remember_token_expires_at}")
      if is_anonymous?
        break if !User.find_by_remember_token(self.remember_token)
      else
        break
      end
    end
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def tagged_lists
    self.task_lists.find(:all,:include=>:taggings,:conditions=>'taggings.id is not null')
  end

  def set_chpass_token
    loop do
      token=ProjectUtils.random_token
      token_exists=User.find_by_chpass_token(token)
      self.chpass_token = token and break unless token_exists
    end
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      #crypted_password.blank? || !password.blank?
      crypted_password.blank? || !password.nil?
    end
end

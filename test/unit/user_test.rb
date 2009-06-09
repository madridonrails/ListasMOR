require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  #fixtures :users

  def test_invalid_with_blank_attributes
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:password)
    assert !user.errors.invalid?(:password_confirmation)
    assert user.errors.invalid?(:email)
    assert user.errors.invalid?(:email_confirmation)
    
  end
  
   def test_invalid_with_used_email
    user = new_user
    user.email = 'baz@baz.com'
    assert user.valid?
    assert !user.errors.invalid?(:password)
    assert !user.errors.invalid?(:password_confirmation)
    assert !user.errors.invalid?(:email)
    
  end
 
  def test_valid_user
    user = new_user
    user.email = 'baz@baz.com'
    user.email_confirmation= 'baz@baz.com'
    assert user.valid?
    assert user.save
  end
  
   private
  
  def new_user
    User.new :first_name => 'Baz', :last_name => 'Baz', 
      :password => 'bazbaz', :password_confirmation => 'bazbaz', 
      :email=>'baz@baz.com', :email_confirmation=>'baz@baz.com'
  end
end

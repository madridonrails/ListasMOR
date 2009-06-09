require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.

  fixtures :users

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
    @request.user_agent = 'Firefox'
  end

  def test_should_login_and_redirect
    post :login, :email => 'foo@bar.com', :password => 'test'
    assert_response :redirect
    assert_redirected_to 'task_lists/list'
  end
  
  def test_should_fail_login_and_not_redirect
    post :login, :login => 'foo@bar.com', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
    assert_template 'login'
  end
  
  def test_should_logout
    login_as :foo
    get :logout
    assert_nil session[:user]
    assert_response :redirect
    assert_redirected_to 'public/index'
  end
  
  def test_chpass
    post :chpass, :password => 'newpassword',:password_confirmation => 'newpassword',:chpass_token => 'token'
    assert_redirected_to '/'
  end
  
  def test_should_fail_chpass
    post :chpass, :password => 'newpassword',:password_confirmation => 'newpassword',:chpass_token => 'bad token'
    assert_response :redirect
    assert_redirected_to '/'
  end
end

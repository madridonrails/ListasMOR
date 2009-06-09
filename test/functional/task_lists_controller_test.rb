require File.dirname(__FILE__) + '/../test_helper'
require 'task_lists_controller'

# Re-raise errors caught by the controller.
class TaskListsController; def rescue_action(e) raise e end; end

class TaskListsControllerTest < Test::Unit::TestCase
  
  fixtures :users, :task_lists, :tasks, :task_list_users
  
  def setup
    @controller = TaskListsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.host = "foo.#{DOMAIN_NAME}"
    @request.user_agent = 'Firefox'
  end
  
  def test_list
    get :list
    assert_response :success
    assert_template 'list'
  end
  
  def test_task_list_add
    login_as :foo
    post :task_list_add, :task_list =>{:user_id =>'1', :name =>'test_list_3', :public => 0, :updated_at => '2007-02-05 18:33:14 +01:00'}
    assert_response :redirect
    assert_redirected_to "task_list/list"
  end
end

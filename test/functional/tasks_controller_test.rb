require File.dirname(__FILE__) + '/../test_helper'
require 'tasks_controller'

# Re-raise errors caught by the controller.
class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < Test::Unit::TestCase
  
  fixtures :users, :task_lists, :tasks, :task_list_users
    
  def setup
    @controller = TasksController.new
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
  
  def test_task_item_add
    login_as :foo
    @list_id = TaskList.find_by_id(:all)
    post :task_item_add, :task => {:task_list_id =>@list_id, :name =>'task_list_3', :closed => 0, :updated_at => '2007-02-05 18:33:14 +01:00'}
    assert_response :success
    assert_template 'task_item'
  end
  
  def test_delete
    login_as :foo
    post :delete, :id => :test_task_2.id
    assert_response :redirect
    assert_redirected_to 'task_list/task'   
  end
end

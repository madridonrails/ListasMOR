require File.dirname(__FILE__) + '/../test_helper'

class TaskListTest < Test::Unit::TestCase
  
  def test_invalid_with_blank_attributes
    task_list = TaskList.new
    assert task_list.valid?
    assert !task_list.errors.invalid?(:task_list_id)
    assert !task_list.errors.invalid?(:name)
    assert !task_list.errors.invalid?(:user_id)
  end
  
  def test_valid_task_list
    task_list = TaskList.new :name => 'Valid Task List', :user_id => '2'
    assert task_list.valid?
    assert task_list.save
  end
end

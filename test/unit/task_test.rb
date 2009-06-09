require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase

  def test_invalid_with_blank_attributes
    task = Task.new
    assert task.valid?
    assert !task.errors.invalid?(:task_list_id)
    assert !task.errors.invalid?(:name)
  end
  
  def test_valid_task
    @task = TaskList.find(:first)
    task = Task.new :name => 'Valid Task', :task_list_id => @task.object_id
    assert task.valid?
    assert task.save
  end
end

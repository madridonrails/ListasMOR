class TasksController < ApplicationController
  before_filter :task_write_permission
  
  
  in_place_edit_for :task, :name
  
  def task_write_permission
    return false if params[:task_list_id].blank?
    
    write_access? params[:task_list_id]
  end
  
  
  def task_item_add    
    render :nothing=>true, :status=>404 and return if !request.xhr? || params[:task_name].blank?
    
    list=TaskList.find(params[:task_list_id])
    task=Task.create(:task_list_id=>list.id,:name=>params[:task_name],:tag_list=>list.tag_list)
    render :partial=>'task_item', :locals=>{:task_item=>task, :write_access=>true}
  end
  
  def delete
    render :nothing=>true, :status=>404 and return if(!request.xhr? || params[:id].blank?)
    Task.destroy(params[:id])
    render :nothing=>true
  end
  
  def toggle_closed
    render :nothing=>true, :status=>404 and return unless(request.xhr? && !params[:id].blank?)
    @task=Task.find(params[:id])
    @task.toggle!(:closed)
  end
  
  def update
    return unless request.post?
    
    task_id=params[:task][:id]    
    @task=(task_id.blank?) ? (Task.new) : (Task.find(task_id) rescue Task.new)
    
    
    params[:task][:cached_tag_list]=params[:task][:tag_list]
    @task.user_id = current_user.id if @task.user_id.blank?
    
    @successful = false
    @successful = @task.update_attributes(params[:task]) 
        
    if @successful
      render :partial=>'task_item_detail', :locals=>{:task_item=>@task, :tr_id=>params[:tr_id]}
    else
      render :action=>'task_form'
    end
    
  end
  
  
end

class TaskListsController < ApplicationController
  before_filter :login_filter, :except=>[:tasks,:tag_search_results]
     
  def set_task_list_name    
    @item = TaskList.find(params[:id])
    read_access, write_access=check_task_list_access(@item)
    return unless write_access
    @item.update_attribute(:name, params[:value])
    render :update do |page|
      page["current_task_list_name_#{params[:id]}_in_place_editor"].replace_html(@item.name)
      page << "if($('active_tab_for_list_#{params[:id]}')) $('active_tab_for_list_#{params[:id]}').update('#{truncate(@item.name,15)}') "  
    end
  end
  
  def set_task_list_tag_list    
    @item = TaskList.find(params[:id])
    read_access, write_access=check_task_list_access(@item)
    return unless write_access
    @item.update_attribute(:tag_list, params[:value])    
    render :text=>@item.tag_list
  end

  def list
    open_lists_param = params[:only_open_lists]
    
    @only_open_lists = (!open_lists_param.blank?) && (open_lists_param.strip.downcase=='true')
    
    user_id=current_user.id
    my_lists=current_user.task_lists
    my_allowed_lists=TaskList.find(:all,:include=>:task_list_users,:conditions=>['task_list_users.user_id=? OR task_list_users.email = ?',user_id,current_user.email])
    
    #in case a shared list was assigned by email before the user signed up, we will fill the user id now
    my_allowed_lists.each do |curr_list|
      curr_list.task_list_users.each do |curr_list_user|
        if curr_list_user.user_id.blank?
          curr_list_user.user_id = user_id
          curr_list_user.save
        end
      end
    end
    
    @closed_lists, @open_lists=my_lists.partition {|l| l.closed?}
    @allowed_closed_lists, @allowed_open_lists=my_allowed_lists.partition {|l| l.closed?}
  end
  
  def edit_dialog
    @task_list = params[:id].blank? ? TaskList.new : TaskList.find(params[:id])    
    render :partial=>'edit_dialog'
  end
  
  def copy_dialog
    @task_list = params[:id].blank? ? TaskList.new : TaskList.find(params[:id])    
    render :partial=>'copy_dialog'
  end
  
  def task_list_copy
    @task_list = TaskList.find(params[:task_list_id])
    new_task_list=TaskList.create(@task_list.attributes.merge(:name=>params[:new_task_name]))
    @task_list.tasks.each do |curr_task|
      new_task=Task.new(curr_task.attributes)
      new_task.task_list_id=new_task_list.id
      new_task.save
    end
  end
  
  def tasks_reorder    
    @task_list = params[:id].blank? ? TaskList.new : TaskList.find(params[:id])
    @read_access, @write_access=check_task_list_access(@task_list)
    render :partial=>'tasks_reorder'
  end
  
  def tasks_reorder_update    
    task_ids=params[:task_ids] || []
    task_ids.each_with_index do |id,ix|
      task=Task.find(id)
      write_access||=check_task_list_access(task.task_list)
      break unless write_access
      task.position=ix+1
      task.save
    end
  
    render :nothing =>true
  end
  
  
  def toggle_closed
    render :nothing=>true, :status=>404 and return unless(request.xhr? && !params[:id].blank?)    
    @task_list=TaskList.find(params[:id])
    read_access, write_access=check_task_list_access(@task_list)
    
    @task_list.toggle!(:closed) unless !write_access
  end
  
  def toggle_public
    render :nothing=>true, :status=>404 and return unless(request.xhr? && !params[:id].blank?)    
    task_list=TaskList.find(params[:id])    
    read_access, write_access=check_task_list_access(task_list)    
    task_list.toggle!(:public) unless !write_access
    
    render :update do |page|
      page.replace_html 'public_access_placeholder', :partial=>'public_access_info', :locals=>{:task_list=>task_list}
    end
  end
  
  def update
    return unless request.post?
    
    if !logged_in?
      #XXX create_anonymous_user
    end
    
    task_list_id=params[:task_list][:id]    
    @task_list=(task_list_id.blank?) ? (TaskList.new) : (TaskList.find(task_list_id) rescue TaskList.new)
    if @task_list.new_record?
      @task_list.user_id = current_user.id
    else  
      @task_list.errors.add_to_base 'usuario incorrecto' if current_user.id != @task_list.user_id
    end

    params[:task_list][:cached_tag_list]=params[:task_list][:tag_list]
    @successful = false
    @successful = @task_list.update_attributes(params[:task_list]) if @task_list.errors.empty?
    
        
    if @successful
      redirect_to :controller=>'task_lists', :action=>'tasks', :id=>@task_list.id
    else
      redirect_to :controller=>'task_lists', :action=>'list'
    end
    
  end
  
  def task_list_form
    @task_list = params[:id].blank? ? TaskList.new : TaskList.find(params[:id])
  end
 
  def task_list_add    
    render :nothing=>true, :status=>404 and return  if !request.xhr? || params[:task_list_name].blank?
    
    if !logged_in?
      create_anonymous_user
    end
    task_list=TaskList.create(:name=>params[:task_list_name], :user_id=>current_user.id)
    render :partial=>'task_list_item', :locals=>{:task_list_item=>task_list}
  end
  
  def delete
    render :nothing=>true, :status=>404 and return if(!request.xhr? || params[:id].blank?)
    TaskList.destroy(params[:id])
    current_user.deactivate_list(params[:id])
    render :nothing=>true
  end
  
  def tasks
    begin      
      task_list_id=params[:id]
      token = params[:token]
      session[:token] = token unless token.blank?
      
      @task_list=TaskList.find(task_list_id)
      @read_access, @write_access=check_task_list_access(@task_list)
      
      redirect_to '/' and return unless @read_access      
    rescue Exception => e
      redirect_to :back and return
    end   
    
    if ( current_user.is_a?(User) && !current_user.active_list?(task_list_id) )
      current_user.set_active_list(@task_list)
      current_user.reload
    end
  
    render
  end
  
  def deactivate
    current_user.deactivate_list(params[:id])
    redirect_to :action=>'list'
  end
  
  
  def tag_search_results    
    @lists_array = Array.new
    
    
    @tag_list=params[:tag_list] || ''
    @local_search = params[:local_search] && params[:local_search] == '1' 
    @text_to_search = params[:text_to_search]
    
    unless params[:show_last_resultset].blank? || session[:last_search].nil?
      @text_to_search=session[:last_search][:text_to_search]
      @tag_list=session[:last_search][:tag_list]
      @local_search=session[:last_search][:local_search]
      @lists_array=session[:last_search][:results]      
      render and return
    end
    
    render and return if @tag_list.blank? && @text_to_search.blank?
    
    token=session[:token] || '-1'
    conditions = search_scope_conditions(@local_search ? current_user.id : nil, token) 
     
    unless @text_to_search.blank?
      add_condition_to_array(conditions,"AND lower(task_lists.name) like ?","%#{@text_to_search.downcase.strip}%")
    end    
    lists = if @tag_list.blank?
      if @text_to_search.blank?
        []
      else
        TaskList.find(:all,:conditions=>conditions,:include=>:task_list_users,:limit=>21)
      end      
    else
      TaskList.find_tagged_with(@tag_list,:conditions=>conditions,:include=>:task_list_users,:limit=>21)
    end
    
    unless lists.empty?
      lists.each do |list|
        @lists_array<<list      
      end
      @lists_array.map!{|l| {:id=>l.id,:name=>l.name}}
    end
    
    session[:last_search] = {:text_to_search=>@text_to_search,:tag_list=>@tag_list,:local_search=>@local_search,:results=>@lists_array}     
    
    
#     @tasks_hash= Hash.new{|h,k| h[k]=Array.new}    
#     tasks = Task.find_tagged_with(tag_list, :include=>:task_list, :conditions=>conditions)
#    tasks.each do |task|
#      @lists_array << task.task_list if @lists_array.select{|l| l.id == task.task_list_id}.empty?
#      @tasks_hash[task.task_list_id] << task
#    end
    
  end
  
  def email_dialog
    render :nothing=>true and return if params[:id].blank?
    @task_list = TaskList.find(params[:id])
    render :partial=>'email_dialog'
  end
  
  def email_list
    render :nothing_true and return if params[:id].blank?    
    @task_list = TaskList.find(params[:id])
    @email_list = params[:email_list] || ''
    @email_text = params[:email_text]
    @email_list.downcase!    
    
    email_array=@email_list.gsub(/\n/,',').gsub(/\s/,'').split(',')
    
    UserNotifier.deliver_send_list(current_user,:task_list=>@task_list,:email_text=>@email_text,:email_array=>email_array)
  end
  
  def share_dialog
    render :nothing=>true and return if params[:id].blank?
    @task_list = TaskList.find(params[:id])
    @read_access,@write_access=check_task_list_access(@task_list)
    render :partial=>'share_dialog'
  end
 
  def share
    render :nothing_true and return if params[:id].blank?    
    task_list = TaskList.find(params[:id])
    read_access,write_access=check_task_list_access(task_list)
    
    if write_access
      email_list = params[:email_list] || ''
      invite_text = params[:invite_text]
      invite_to_write = params[:invite_to_write].to_i rescue 0
      
      
      email_list.downcase!    
      email_array=email_list.gsub(/\n/,',').gsub(/\s/,'').split(',')
      email_array.each do |email|
        continue if email==current_user.email
        tlu=TaskListUser.find_or_initialize_by_task_list_id_and_email(task_list.id,email)
        new_record= tlu.new_record?
        if new_record
          user=User.find_by_email(email)
          tlu.user_id=user.id if user          
        end
        tlu.read_only=invite_to_write == 1 ? false : true
        tlu.save
        
        if new_record || tlu.user_id.blank?
          invite_url = url_for(:controller=>'task_lists',:action=>'tasks',:id=>task_list.id,:token=>tlu.token)        
          UserNotifier.deliver_send_invite(current_user,:email=>email,:invite_url=>invite_url,:invite_text=>invite_text,:is_registered_user=>!tlu.user_id.blank?)
        end
      end
      
      email_list_for_sql = "'" + email_array.join("','") + "'"
      TaskListUser.delete_all("task_list_id=#{task_list.id} AND email NOT IN (#{email_list_for_sql})")
    end
    @task_list=task_list
    
    render :partial=>'share_dialog'
  end
  
  
  private
  
  def set_top_box_text
    @top_box_title=local_html(:global,:did_you_know)
    @top_box_text=local_html(:task_list,:tags_explanation)
  end
  
  
  def search_scope_conditions(user_id=nil,token=nil)
    if user_id && logged_in? && current_user.id==user_id                  
      ['(task_lists.public=1 OR task_lists.user_id = ? OR task_list_users.user_id=? OR task_list_users.token=? )',user_id,user_id,token]
    else  
      if logged_in?
        ['(task_lists.public=1 OR task_lists.user_id=? OR task_list_users.token=?)',current_user.id,token]
      else
        ['(task_lists.public=1 OR task_list_users.token=?)',token]
      end
    end
  end
  
  def add_condition_to_array(cond_array,condition,params=nil)
    cond_array[0] = cond_array[0] + " #{condition} "
    if params
      params=[params] unless params.is_a?(Array)
      cond_array.concat params
    end
  end
end

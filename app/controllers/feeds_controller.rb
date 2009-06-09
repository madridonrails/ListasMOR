class FeedsController < ApplicationController
  session :off
  layout nil
  skip_before_filter :login_from_cookie, :get_params_for_sorting, :set_controller_and_action_names, :set_back_controller_and_action_names
    
  def user_lists
    user_id=params[:id].to_i
    auth_user=check_feed_authorization
    
    deny_access and return nil if (auth_user.nil? || auth_user.id != user_id)
      
    tasks = Task.find(:all,:conditions=>['task_lists.user_id=?',user_id],:order=>'tasks.created_at DESC', :limit=>200, :include=>:task_list)
    @items=feedify(tasks, :title=>'name',:author=>'user.fullname',:controller=>'task_lists', :action=>'tasks', :id_method=>'task_list_id')
    
    headers["Content-Type"] = "application/rss+xml"
    render :template=>'feeds/feed_template'
  end
  
  def list
    list_id=params[:id].to_i
    token=params[:token]
    
    render(:nothing=>true, :status=>403) and return if list_id.blank? || token.blank?
    
    list = TaskList.find(list_id,:include=>{:tasks=>:user}, :conditions=>['task_lists.token=?',token])
    
    #unless list.public?    
    #  auth_user=check_feed_authorization
    #  user_allowed=(auth_user.nil? || list.user_id != auth_user.id) ? nil : auth_user
    #  deny_access and return nil if (auth_user.nil? || user_allowed.nil? )
    #end  
    
    tasks = list.tasks.sort{|x,y| x.position <=> y.position}[0...200]
    
    @items=feedify(tasks, :title=>'name',:author=>'user.fullname',:controller=>'task_lists', :action=>'tasks', :id_method=>'task_list_id')
    @title=list.name
    @description=list.description
    
    headers["Content-Type"] = "application/rss+xml"
    render :template=>'feeds/feed_template'    
  end
    
  private
  
  def feedify(item_list,options)    
    items=Array.new
    
    return item if item_list.nil?
    
    item_list.each do |item|
      feed_item=FeedItem.new
      feed_item.title=item.send(options[:title]||:title) 
      feed_item.pubDate=(options[:pub_date] ? item.send(options[:pub_date]) : Time.now) rescue nil
      feed_item.author=item.send(options[:author]||:author) rescue nil 
      item_id=if options[:id_method]
        item.send(options[:id_method])
      elsif options[:id_external_method]
        eval "#{options[:id_external_method]} item"
      else
        item.id
      end rescue nil
    
      link=if options[:url]
        "#{options[:url]}#{item_id}"
      elsif options[:controller]
        url_for(:only_path => false,:id => item_id, :controller => options[:controller] , :action=>options[:action]  )
      else
        nil
      end rescue nil
      feed_item.link=link
      
      feed_item.guid=if (options[:guid_as_link])
        feed_item.isPermaLink=true
        link
      elsif options[:guid]
        item.send(options[:guid])
      else
        item.id
      end rescue item.id      
      
      items << feed_item unless feed_item.title.nil?
    end
    items
  end
  
  def check_feed_authorization
    if request.env.has_key? 'X-HTTP_AUTHORIZATION' 
      # try to get it where mod_rewrite might have put it 
      authdata = @request.env['X-HTTP_AUTHORIZATION'].to_s.split 
    elsif request.env.has_key? 'HTTP_AUTHORIZATION' 
      # this is the regular location 
      authdata = @request.env['HTTP_AUTHORIZATION'].to_s.split  
    end 
     
    # at the moment we only support basic authentication
    @allowed_user=nil 
    if authdata and authdata[0] == 'Basic' 
      email,password=Base64.decode64(authdata[1]).split(':')[0..1]
      @allowed_user = User.authenticate(email,password)      
    end
    
    if @allowed_user
      return @allowed_user
    else
      #deny_access 
      return nil
    end  
  end
  
  def deny_access
    @response.headers["WWW-Authenticate"] = "Basic realm=\"listasgems\""
      render :nothing=>true, :status=>401
  end
end

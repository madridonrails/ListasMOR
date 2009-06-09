class PublicController < ApplicationController  
  session :off
  
  def index    
  end
  
  def contact
  end
  
  def tour
    @current_view = @current_action
    @current_section = ProjectUtils.normalize(params[:section])    
    unless @current_section.blank? 
      @current_view = @current_action + "_#{@current_section}"
    end
    render :action => @current_view, :layout => true
  end
  
  def help
    @current_view = @current_action
    @current_section = ProjectUtils.normalize(params[:section])    
    unless @current_section.blank? 
      @current_view = @current_action + "_#{@current_section}"
    end
    render :action => @current_view, :layout => true
  end

  def home
  end

  def signup
    redirect_to :controller=>'account', :action=>'signup'
  end
  
  def login
    redirect_to :controller=>'account', :action=>'login'
  end
  
  
  def image
    send_hot_editable_media('images')
  end

  def video
    send_hot_editable_media('videos')
  end
  
  #To check Exception Notifier
  def error  
    raise RuntimeError, "Generating an error"  
  end 
  
  def send_hot_editable_media(kind)
    if params[:filename].blank?
      render :nothing => true
    else
      # We are going to access the disk, so be extra-careful with the parameter.
      # Rails unescapes %XXs, but the normalizer would filter them all anyway.
      filename = ProjectUtils.normalize_filename(File.basename(params[:filename]))
      begin
        send_file("#{RAILS_ROOT}/app/hot_editable/#{kind}/#{filename}", :disposition => 'inline')
      rescue
        # this is raised if you try to access a non-existing filename
        logger.info("we received a request for the invalid #{kind.singularize} '#{params[:filename]}'")
        render :nothing => true
      end
    end    
  end
  private :send_hot_editable_media
   
    
  def __update_hot_editable
    # raise ActionController::UnknownAction unless request.put?
    @ip = request.remote_ip
    msg = "updating hot_editable from IP #@ip"
    logger.info(msg)
    Dir.chdir("#{RAILS_ROOT}/app/hot_editable") do
      @svn = `svn up`
    end
    
    render :action => '__update_hot_editable', :layout => false
  end
  
 end

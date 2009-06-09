# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  include AuthenticatedSystem  
  include LocalTextHelper  
  helper LocalTextHelper
  
  before_filter :login_from_cookie
  before_filter :get_params_for_sorting
  before_filter :set_controller_and_action_names
    
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_listasgem_mor_session_id'
   
  filter_parameter_logging :password
  
  # Inspired by http://jroller.com/page/obie?entry=wrestling_with_the_bots
  session :off, :if => lambda { |req|
    req.user_agent =~ %r{
      Baidu        |
      Gigabot      |
      Google       |
      libwww-perl  |
      lwp-trivial  |
      msnbot       |
      SiteUptime   |
      Slurp        |
      WordPress    |
      ZIBB         |
      ZyBorg       |
      Yahoo        |
      Lycos_Spider |
      Infoseek
    }xi
  }
  
  def get_params_for_sorting
    params_for_sorting=['first_name', 'last_name']
    params_for_sorting.each do |param|
      params["#{param}_for_sorting"] = StrNormalizer.normalize_for_sorting(params[param]) unless params[param].nil?
    end 
  end
  
  def is_admin_user?
    return (logged_in? && current_user.is_admin?)
  end
  helper_method :is_admin_user?
  
  
  def admin_filter
    unless is_admin_user?
      redirect_to '/'
      return false
    end
  end
  
  def login_filter
    unless logged_in?
      redirect_to :controller=>'account',:action=>'login'
      return false
    end
  end
  
    def check_task_list_access(task_list,token=nil)
    task_list=TaskList.find(task_list) unless task_list.is_a?(TaskList) rescue TaskList.new
    task_list_id=task_list.id
    token||=params[:token]||=session[:token]
    write_access=false
    read_access=false
      
    read_access = true if task_list.public?
    
    if logged_in? 
      if task_list.user_id == current_user.id
        write_access = true
        read_access = true
      elsif task_list_user=TaskListUser.find_by_task_list_id_and_user_id(task_list_id,current_user.id)
        read_access = true
        write_access = !task_list_user.read_only?
      end
    elsif token && task_list_user=TaskListUser.find_by_task_list_id_and_token(task_list_id,token)      
      invited_user_email=task_list_user.email
      read_access = true
      write_access = !task_list_user.read_only?
    end
    return read_access,write_access
  end
  
  
  def read_access?(task_list,token=nil)
    read_access,write_access=check_task_list_access(task_list,token)
    read_access
  end
  helper_method :read_access?
  
  
  def write_access?(task_list,token=nil)
    read_access,write_access=check_task_list_access(task_list,token)
    write_access
  end
  helper_method :write_access?

  
  def set_controller_and_action_names
    @current_action     = action_name
    @current_controller = controller_name
    
  end
  protected :set_controller_and_action_names
  
  def create_anonymous_user    
    self.current_user=User.new
    self.current_user.remember_me(true)
    cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    return self.current_user
  end
  
  def user_logout
    current_user.forget_me if logged_in?
    cookies.delete :auth_token
    language = get_local_language    
    reset_session
    set_local_language(language)    
    redirect_to '/'
  end
  helper_method :user_logout
  
    def hot_editable_filename(name)
    name = name.sub(/\.rhtml$/, '') # .rhtml is optional
    "#{RAILS_ROOT}/app/hot_editable/views/#{name}.rhtml"
  end
  
  def exists_hot_editable_file?(name)
    File.exists?(hot_editable_filename(name))
  end
  
  def hot_editable_file(name, options={})
    render({:file => hot_editable_filename(name)}.merge(options))
  end
  helper_method :hot_editable_file
  

end

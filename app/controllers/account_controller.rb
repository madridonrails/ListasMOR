class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  before_filter :login_filter, :only=>[:logout, :signout]
  
  def login
    return if request.get?
     
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
       set_local_language(current_user.language)
      #Para recordar el login
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }      			
      redirect_back_or_default(:controller => 'task_lists', :action => 'list')
    else
      flash.now[:notice] = local_html(:login,:login_failure)
      render :action => 'login'				      
    end
  end

    
  def signout

    messages = []
    
    @user=(logged_in?) ? current_user : User.new
    language = LocalText.default_language.to_s if @user.language.blank?
     
    @new_user=@user.new_record?
    
    if @new_user  
      # Check email and signout_code
      email = params[:user][:email]
      signout_code = params[:user][:signout_code]
      messages << LocalText.text(language,:signout, :signout_code_mandatory) if signout_code.blank? 
      messages << LocalText.text(language,:signout, :email_mandatory) if email.blank? 
    else
      # check password
      password = params[:user][:password]
      messages << LocalText.text(language,:signout, :password_incorrect) if (password.blank? || !current_user.authenticated?(password))
    end
    
    if messages.empty?
      @user = User.find_by_email(email, :conditions => ['signout_code = ?',signout_code]) if @new_user
      unless @user.blank?
        @user.signout
        begin
          UserNotifier.deliver_signout_notification(@user)
        rescue
          PendingMail.enqueue_mail(:signout_notification, @user.id)
        end
        messages << LocalText.text(language,:signout, :signout_ok)
      else
        messages << LocalText.text(language,:signout, @new_user? :parameters_incorrect : :password_incorrect)
      end     
    end  
    
    render :update do |page|
      page.replace_html( 'response_div', content_tag(:ul, messages.map {|msg| content_tag(:li, msg) }) + '<br/>' )
    end	  
  
  end
  
  def logout
    user_logout            
  end
    
  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.errors.error_language=get_local_language
    @user.save!
    @user.remember_me
    if current_user && current_user.is_a?(User) && current_user.task_lists
      current_user.task_lists.each do |list|
        list.user_id = @user.id
        list.save
      end
      User.destroy(current_user.id)
    else
      @user.create_default_task_list
    end
      
    self.current_user = @user
    redirect_to '/'
    rescue ActiveRecord::RecordInvalid
    flash.now[:notice] = local_html(:signup, :signup_failure)
    render :action => 'signup'
  end

  def send_chpass_instructions
    email=params[:email]
    if request.post? && !email.blank?
      begin
        user=User.find_by_email(email)
        flash[:notice] = local_html(:chpassword,:user_not_found) and return if user.blank?
       
        user.set_chpass_token
        user.save
                
        url_for_chpass = url_for :action => 'chpass', :chpass_token => user.chpass_token
        UserNotifier.deliver_chpass_instructions(user,:url_for_chpass=>url_for_chpass)
        flash[:notice] = local_html(:chpassword,:mail_sent)
      rescue Exception => e
        flash[:notice] = local_html(:chpassword,:mail_error)
      end
    end     
  end

  def chpass    
    @chpass_token = params[:chpass_token]
    @user = @chpass_token.blank? ? nil : User.find_by_chpass_token(@chpass_token)
    
    redirect_to :action => 'login' and  return if @chpass_token.blank? || @user.blank?      
      
        
    if request.post?
      @user.password              = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      if @user.save
        # chpass tokens are one shot for security reasons
        @user.chpass_token = nil
        @user.save
        
        # log the user in automatically
        self.current_user = User.authenticate(@user.email, @user.password)
        redirect_to "/" and return
      else
        flash[:notice] = local_html(:chpassword,:password_error)
      end
    end
    
    render :action => 'chpass'
  end  

end

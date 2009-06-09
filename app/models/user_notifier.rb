class UserNotifier < ActionMailer::Base
  
  
  def signout_notification(user,params=nil)
    #XXX
    user=get_user_object(user)
    setup_email(user)
    language = LocalText.default_language
    @body[:language]=language
    @subject    += LocalText.text(@body[:language],:signout_notification_mail, :subject)
    @recipients  = ConfigVar.get_var(:admin_email)
  end
  
  def chpass_instructions(user,params)
    user=get_user_object(user)
    setup_email(user)
    @body[:url_for_chpass]=params[:url_for_chpass]
    @subject += LocalText.text(@body[:language],:chpassword, :mail_subject)  
  end
  
  def activation(user,params=nil)    
    user=get_user_object(user)
    setup_email(user)  
    @from=user.email
    @subject += LocalText.text(@body[:language],:activation_mail, :subject)       
  end
  
  def send_invite(current_user, params=nil)
    current_user=get_user_object(current_user)
    
    email_to=params[:email]
    invite_text=params[:invite_text]
    invite_url=params[:invite_url]
    setup_email(current_user)
    @from=current_user.email
    
    language=@body[:language]
                
    @recipients=email_to
    
    @subject += LocalText.text(language,:mail,:share_list_subject)    
    @body[:invite_url] = invite_url
    @body[:invite_text] = invite_text           
  end
  
  def send_list(current_user, params=nil)
    current_user=get_user_object(current_user)
    
    task_list=params[:task_list]
    email_text=params[:email_text]
    email_array=params[:email_array]
    setup_email(current_user)
    @from=current_user.email
    
    language=@body[:language]
                
    @recipients=nil
    @bcc=email_array
    
    @subject += LocalText.text(language,:mail,:email_list_subject) 
    @body[:email_text] = email_text
    @body[:task_list] = task_list
  end
  
  def new_password(user,params=nil)
    #XXX
    user=get_user_object(user)
    password=params[:password]
    setup_email(user)   
    language=user.language.blank? ? LocalText.default_language : user.language
    @subject += LocalText.text(language,:new_password_mail, :subject)
    @body[:password] = password     
  end
  
  
  protected
  def setup_email(user, url_base="http://#{HOST}")
    @recipients  = "#{user.email}"    
    @headers = {'Sender'=> FROM_EMAIL}
    @from        = user.email
    @subject     = "[listasgem] "
    @sent_on     = Time.now
    @charset = 'utf-8'
    @content_type = 'text/html' 
    @body[:user] = user    
    @body[:language] = user.language.blank? ? LocalText.default_language : user.language    
    @body[:url_base] = url_base
  end
  
  
  def get_user_object(user)
    user=User.find(user) unless user.is_a? User #we accept both id and user object
    user
  end
 
end

class UsersController < ApplicationController
  before_filter :admin_filter, :except=>[:profile_dialog, :save_profile, :beruby]
  before_filter :admin_or_self, :except => [:beruby]
  
  def list
    order_by_fields = ['email','created_at','is_admin']
    
    @current_order_by=session[:users_order_by]  = params[:order_by].to_i || session[:users_order_by].to_i || nil 
    @current_direction=session[:users_order_direction] = params[:direction] || session[:users_order_direction] || 'ASC'
        
    @users =  if @current_order_by                
                User.paginate :all, :order=>"#{order_by_fields[@current_order_by]} #{@current_direction}", :page => params[:page]
              else
                User.paginate :all, :page => params[:page]
              end
    
    
    render :layout=>false if request.xhr?
  end
  
  def profile_dialog
    @user = (is_admin_user? && params[:user_id]) ? User.find(params[:user_id]): current_user    
    render :partial=>'profile_dialog'
  end
  
  def save_profile
    @user=User.find_by_id(params[:id])
    return unless request.xhr? || params[:id].blank? || @user.nil?
        
    attr=params[:user]
    attr[:password] = nil if attr[:password].blank? &&  attr[:password_confirmation].blank?
    
    @user.errors.error_language=get_local_language
    @user.update_attributes(attr)
    
    if @user.save
      render :update do |page|
        page.call 'location.reload'
      end
    else
      render :update do |page|
        page.replace_html 'errors_div', error_messages_for_with_localization(:user)
      end
    end
    
  end
  
  def toggle_admin_user
    @user=User.find_by_id(params[:id])
    return unless request.xhr? || params[:id].blank? || @user.nil?
    @user.toggle!(:is_admin)
    
    render :update do |page|
      page.replace_html "span_admin_user_#{@user.id}", user_admin_toggler(@user)      
    end
    
  end
  
  def delete_user
    @user=User.find_by_id(params[:id])
    return unless request.xhr? || params[:id].blank? || @user.nil?
    
    @user.destroy
    
    if current_user.id == params[:id] 
      user_logout and return
    else
      render :update do |page|
        page.call 'location.reload'
      end
    end
  end
  
  def beruby
    if current_user
      current_user.beruby_visited = true
      current_user.save
    end
  end

  protected
  def admin_or_self
    logged_in? && (current_user.is_admin? || current_user.id.to_s == params[:id].to_s) 
  end
end

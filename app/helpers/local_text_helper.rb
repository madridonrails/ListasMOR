module LocalTextHelper
  def get_local_language
    session[:language]=params[:session_language] unless params[:session_language].blank?
    language=if session[:language] 
      session[:language]
    elsif logged_in?
      session[:language] = current_user.language.to_s || LocalText.default_language
    else
      session[:language] = LocalText.default_language
    end    
    language=session[:language] = LocalText.default_language unless LocalText.languages.include? language 
    language
  end
  
  def set_local_language (language)
    session[:language] = language
  end
  
  def language_list
    LocalText.languages  
  end
  
  def local_html(category,entry,*params)
    LocalText.html(get_local_language,category,entry,params)
  end
  
  def local_text(category,entry,*params)
    LocalText.text(get_local_language,category,entry,params)
  end
  
  def local_months
    months=local_text(:global,:month_names).split(/[\s]+/)
    months.each_with_index{|m,i| months[i]="*#{m}".squeeze('*')} if months[0].starts_with?('*')  
    months    
  end
  
  def local_days
    days=local_text(:global,:day_names).split(/[\s]+/)
    days.each_with_index{|d,i| days[i]="*#{d}".squeeze('*')} if days[0].starts_with?('*')  
    days    
  end
  
  def get_random_captcha_key
    captcha_list = LocalText.category(get_local_language,:captcha)
    captcha_list.keys[rand(captcha_list.size)]
  end
  
  def local_captcha_question(key)
    captcha_list = LocalText.category(get_local_language,:captcha)
    # Remove the answer (between parenthesis) from the result
    captcha_list[key].split(/[\(\)]/)[0] rescue ''
  end
  
  def local_captcha_answer(key)
    captcha_list = LocalText.category(get_local_language,:captcha)
    # Get the answer (between parenthesis) from the result
    captcha_list[key].split(/[\(\)]/)[1]
  end

end
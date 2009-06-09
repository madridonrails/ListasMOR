class LocalTextController < ApplicationController
  session :off, :only=>[:reload_config_files]
  
  def reload_config_files
    render :text=>'KO', :status=>403 and return unless local_request?
    
    LocalText.load_local_strings
    render :text=>'OK'
  end
end

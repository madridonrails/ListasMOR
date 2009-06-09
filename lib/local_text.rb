require 'yaml'
require 'htmlentities'

class LocalText  
  @@local_strings=nil
  @@loaded_languages=nil
  @@html_coder = HTMLEntities.new      
  
  cattr_accessor :default_language
  self.default_language=:es
  cattr_accessor :listening_ports
  self.listening_ports = []
  
  def self.load_local_strings    
     @@local_strings = Hash.new('')
     language_dir=File.expand_path(File.join(RAILS_ROOT,'config','languages'))
     language_files=Dir.open(language_dir) do |d|
        d.select{|entry| File.file?("#{language_dir}/#{entry}") && File.extname("#{language_dir}/#{entry}")=='.yml'}
     end
     @@loaded_languages = Array.new
     language_files.each do |language|
      locale=File.basename(language,'.yml')
      @@local_strings[locale.to_sym]=YAML.load_file(File.join(language_dir,language))
      @@loaded_languages << locale  
     end
  end
  
  public  
  def self.languages
    self.load_local_strings if @@loaded_languages.nil? || @@loaded_languages.empty?
    @@loaded_languages || []    
  end
  
  def self.text(language,category,entry,params=[])
    load_local_strings if @@local_strings.nil? || @@local_strings.empty?
    category=category.to_s.downcase
    entry=entry.to_s.downcase
    text=@@local_strings[language.to_sym][category.to_s][entry.to_s] rescue ''
    if text.blank?
      text=@@local_strings[self.default_language.to_sym][category.to_s][entry.to_s] rescue nil
      text = "#{category.to_s}/#{entry.to_s}" if text.blank?
      text = "*#{text}*"
    end
    if params.empty?
      text.gsub!(/%[^%]+%/,'')
    else
      text=replace_params(text,params)
    end
     
    text
  end
  
  def self.html(language,category,entry,params=[])
    @@html_coder.encode(self.text(language,category,entry,params),:named).gsub("\n","<BR/>")
  end
  
  def self.category(language,category)
    load_local_strings if @@local_strings.nil? || @@local_strings.empty?
    
    category=@@local_strings[language.to_sym][category.to_s] rescue Hash.new
    if category.nil? || category.empty?
      category=@@local_strings[self.default_language.to_sym][category.to_s] || Hash.new rescue Hash.new
    end
     
    category
  end
  
  private
  def self.replace_params(text, params)    
    params=Array.new.push params if params.is_a?(String)
    params.flatten!
    return text unless params.is_a?(Array)    
    parts=text.split('%')    
    output=String.new    
    parts.each_with_index do |part,ix|      
      if ix.odd?        
        param=(params[ix/2] || params[-1])  
        param='' if param.nil?
        if part.include?(',')
          length=part.split(',')[-1].to_i
          if param.length > length
            part=param[0,length]
            part[-3..-1]='...'
          else
            part=param
          end  
        else
          part = param
        end
      end
      output += part      
    end #each_with_index  
    output.strip
  end
end



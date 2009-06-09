#### ----- extensions for error localization

module ActionView
  module Helpers
    module ActiveRecordHelper
      
      def error_messages_for_with_localization (*object_names)
        original_object_names = object_names        
        local_language =  object_names.last.is_a?(Hash) ? object_names.delete_at(-1)[:language] : nil
        local_language ||= LocalText.default_language
        
        object_names = [object_names]
        object_names.flatten!
        app_errors = []
        object_names.each_with_index do |name,ix| 
          object = instance_variable_get("@#{name}")          
          if object            
            new_errors=Hash.new
            new_base_errors=Array.new
            object.errors.each do |key, value|
              if value.match(/^\^/)
                app_errors << value[1..value.length]
              else
                if key.class == String and key == "base"                  
                  new_base_errors << value                 
                else
                  key_name = LocalText.text(local_language, :error_fields, key.to_s.underscore.downcase)
                  #( (object.class.instance_variable_get('@validation_names') &&  
                  #object.class.instance_variable_get('@validation_names')[key.to_s.downcase.to_sym] ) ? 
                  #object.class.instance_variable_get('@validation_names')[key.to_s.downcase.to_sym] : key ) rescue key
                  new_errors[key_name]=value                  
                end
              end
            end
            object.errors.clear
            new_errors.each_pair {|key,value| object.errors.add(key,value) }            
            new_base_errors.each {|value| object.errors.add_to_base(value) }            
          end
        end
        
        params=original_object_names
        options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
        objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        count   = objects.inject(0) {|sum, object| sum + object.errors.count }
        unless count.zero?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
          header_message = LocalText.text(local_language, :default_error_messages, :errors_header)
          error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
          content_tag(:div,
            content_tag(options[:header_tag] || :h2, header_message) <<
              content_tag(:p, LocalText.text(local_language, :default_error_messages, :errors_subheader)) <<
              content_tag(:ul, error_messages),
            html
          )
        else
          ''
        end        
        #return error_messages_for_without_localization(original_object_names,view_partial)
      end
      
      #alias_method_chain :error_messages_for, :localization      
    end
  end
end


class ActiveRecord::Errors   
  #if error_language is set, we'll try to translate the validation messages
  attr_accessor :error_language
  
  def add_with_message_translation(attribute, msg = @@default_error_messages[:invalid])
    unless error_language.nil? #do nothing if not error_language is set
      #we need to get the numbers in the message because some allow numeric parameters inside (for length)
      #if we find any numbers, we need to replace them for %d so the message will look like the original pattern/string 
      arr_numbers=msg.scan(/[\d]+/)  
      msg.gsub!(/[\d]+/,'%d') unless arr_numbers.empty?        
      
      #we look in default_error_messages for the error type corresponding to this string/pattern
      error_type = ActiveRecord::Errors.default_error_messages.invert[msg]
      #if a type is found, we translate the message
      msg=LocalText.text(error_language,:default_error_messages,error_type) if error_type      
      
      #in case we replaced the numbers before, now we need to get them inline again
      msg = msg % arr_numbers unless arr_numbers.empty?      
    end #error_language.nil?
    
    add_without_message_translation(attribute, msg)  #call to the original method with the new message
  end
  
  alias_method_chain :add, :message_translation
end

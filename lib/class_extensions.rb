# The idiomatic way to do this is to write a plugin, but this is good enough and much faster     
class ActiveRecord::Base
  # This class method generates methods like this one:
  #
  # def first_name=(fname)
  #    write_attribute(:first_name, fname)
  #    write_attribute(:first_name_for_sorting, GastosgemUtils.normalize_for_sorting(fname))
  #  end
  def self.add_for_sorting_to(*fields)
    fields.each do |f|
      class_eval <<-EOS
        def #{f}=(v)
          write_attribute(:#{f}, v)
          write_attribute(:#{f}_for_sorting, StrNormalizer.normalize_for_sorting(v))
        end
      EOS
    end
  end
end

class Logger
  def format_message(severity, timestamp, progname, msg)
    if timestamp.is_a? String
      "#{timestamp} (#{$$}) [#{severity}]:#{msg}\n"
    else
      "#{timestamp.strftime('%Y/%m/%d %H:%M:%S')} (#{$$}) [#{severity}]:#{msg}\n"
    end
    
  end
end



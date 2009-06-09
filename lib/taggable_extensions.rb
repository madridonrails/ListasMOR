class TagList
  def size
    self.to_s.size
  end
  
#  def to_s_with_blank_if_empty
#    str=self.to_s_without_blank_if_empty
#    str=' ' if str.blank?
#    str
#  end
#  alias_method_chain :to_s, :blank_if_empty
  
  def add_with_normalization(*names)
    names = names.flatten
    names.map!{|n|StrNormalizer.normalize_for_tag(n)}
    add_without_normalization(names)
  end
  alias_method_chain :add,:normalization
  
  def remove_with_normalization(*names)
    names = names.flatten
    names.map!{|n|StrNormalizer.normalize_for_tag(n)}
    remove_without_normalization(names)
  end
  alias_method_chain :remove,:normalization
end
  
module ActiveRecord::Acts::Taggable::InstanceMethods
  def save_cached_tag_list_with_blank
    if caching_tag_list? and !tag_list.nil?
       self[self.class.cached_tag_list_column_name] = tag_list.to_s
    end
  end
  alias_method_chain :save_cached_tag_list, :blank
end

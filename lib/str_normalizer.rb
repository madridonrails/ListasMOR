class StrNormalizer
  # Utility method that retursn an ASCIIfied, downcased, and sanitized    string.
  # It relies on the Unicode Hacks plugin by means of String#chars. We    assume
  # $KCODE is 'u' in environment.rb. By now we support a wide range of    latin
  # accented letters, based on the Unicode Character Palette bundled in   Macs.
  def self.normalize_for_sorting(str)
    n = self.normalize_letters(str)
    n.gsub!(/\s+/,            '-')
    n
  end
  
  def self.normalize_for_url(str)
    n=self.normalize_for_sorting(str).gsub('-','_')
    n
  end
  
  def self.normalize_for_tag(str)
    n=self.normalize_letters(str)
    n.gsub!(/\s+/, ' ')
    n
  end
  
  def self.normalize_letters(n)
    n = n.chars.downcase.strip.to_s
    n = self.normalize_vowels(n)    
    n = self.normalize_consonants(n)
    n=strip_invalid(n)
    n
  end
  
  def self.normalize_vowels(n)
    n.gsub!(/[àáâãäåāăą]/u,    'a')
    n.gsub!(/æ/u,            'ae')
    n.gsub!(/[èéêëēęěĕė]/u,   'e')
    n.gsub!(/[ììíîïīĩĭ]/u,    'i')
    n.gsub!(/[òóôõöøōőŏŏ]/u,  'o')
    n.gsub!(/[ùúûüūůűŭũų]/u,  'u')
    n.gsub!(/œ/u,            'oe')
    n
  end
  
  def self.normalize_consonants(n)
    n.gsub!(/[ďđ]/u,          'd')
    n.gsub!(/[çćčĉċ]/u,       'c')    
    n.gsub!(/ƒ/u,             'f')
    n.gsub!(/[ĝğġģ]/u,        'g')
    n.gsub!(/[ĥħ]/,           'h')    
    n.gsub!(/[įıĳĵ]/u,        'j')
    n.gsub!(/[ķĸ]/u,          'k')
    n.gsub!(/[łľĺļŀ]/u,       'l')
    n.gsub!(/[ñńňņŉŋ]/u,      'n')
    n.gsub!(/[ŕřŗ]/u,         'r')
    n.gsub!(/[śšşŝș]/u,       's')
    n.gsub!(/[ťţŧț]/u,        't')    
    n.gsub!(/ŵ/u,             'w')
    n.gsub!(/[ýÿŷ]/u,         'y')
    n.gsub!(/[žżź]/u,         'z')
    n
  end
  
  def self.strip_invalid(n)
    n.gsub!(/[^\/\sa-z0-9_-]/,   '')
    n
  end
end
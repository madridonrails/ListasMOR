class ProjectUtils
  # We use 63 tokens and tokens of length 23, which gives 63**23 possible tokens, that's:
  #
  #   242567514087541147634431480398346066867647 (42 digits)
  #
  # enough to prevent brute-force attacks. The 23 was chosen from the length of the keys
  # used in Google Docs in their URLs for sharing.
  @@token_chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['_']
  def self.random_token
    token = ''
    23.times { token << @@token_chars[rand(@@token_chars.length)] }
    token
  end
  
  def self.normalize_for_sorting(str)
    self.normalize(str).tr('_/\\', '-')
  end
  
  def self.normalize_for_url_id(str)
    self.normalize(str).tr(' /\\', '-')
  end
  
  def self.normalize_filename(filename)
    filename.split('.').map {|x| self.normalize(x)}.join('.')
  end
  
  # The trick with iconv does not work in Acens due to the version of the library there.
  def self.normalize(str)
    return '' if str.nil?
    n = str.chars.downcase.strip.to_s
    n.gsub!(/[àáâãäåāă]/,    'a')
    n.gsub!(/æ/,            'ae')
    n.gsub!(/[ďđ]/,          'd')
    n.gsub!(/[çćčĉċ]/,       'c')
    n.gsub!(/[èéêëēęěĕė]/,   'e')
    n.gsub!(/ƒ/,             'f')
    n.gsub!(/[ĝğġģ]/,        'g')
    n.gsub!(/[ĥħ]/,          'h')
    n.gsub!(/[ììíîïīĩĭ]/,    'i')
    n.gsub!(/[įıĳĵ]/,        'j')
    n.gsub!(/[ķĸ]/,          'k')
    n.gsub!(/[łľĺļŀ]/,       'l')
    n.gsub!(/[ñńňņŉŋ]/,      'n')
    n.gsub!(/[òóôõöøōőŏŏ]/,  'o')
    n.gsub!(/œ/,            'oe')
    n.gsub!(/ą/,             'q')
    n.gsub!(/[ŕřŗ]/,         'r')
    n.gsub!(/[śšşŝș]/,       's')
    n.gsub!(/[ťţŧț]/,        't')
    n.gsub!(/[ùúûüūůűŭũų]/,  'u')
    n.gsub!(/ŵ/,             'w')
    n.gsub!(/[ýÿŷ]/,         'y')
    n.gsub!(/[žżź]/,         'z')
    n.gsub!(/\s+/,           ' ')
    n.tr!('^ a-z0-9_/\\-',    '')
    n
  end
  
end
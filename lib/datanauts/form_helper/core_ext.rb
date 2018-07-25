# Patches to allow easy(ish) html outpus
class Symbol
  # :input.tag :name => 'address', :value => 'Foo Road'
  def tag(options = {})
    option_string = (' ' + options.to_html_options).sub(/\s+$/, '')
    "<#{self}#{option_string} />"
  end

  # :div.wrap "Hello", :id => "userbox", :class => "box"
  # :div.wrap(:id => "userbox", :class => "box"){ "Hello" }
  #
  # If you give a content as block and as parameter too, then the parameter
  # will be the default value (in case of the block is empty)
  def wrap(content = nil, options = {}, &block)
    (options = content; content = nil) if content.is_a? Hash
    content = yield || content if block
    option_string = (' ' + options.to_html_options).sub(/\s+$/, '')
    "<#{self}#{option_string}>#{content}</#{self}>"
  end
end

# Useful extensions to hash class
class Hash
  def to_html_options
    (map { |key, value| %(#{key}="#{value}") if value } - [nil]).join(' ')
  end

  def symbolize_keys
    transform_keys { |key| key.to_sym rescue key }
  end

  def symbolize_keys!
    transform_keys! { |key| key.to_sym rescue key }
  end

  def transform_keys
    return enum_for(:transform_keys) unless block_given?
    result = self.class.new
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

  def transform_keys!
    return enum_for(:transform_keys!) unless block_given?
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end
end

# useful patches to string...
class String
  def underscore
    gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
  end

  def humanize
    gsub(/_id$/, '').tr('_', ' ').capitalize
  end

  def titleize
    underscore.humanize.gsub(/\b([a-z])/) { |x| x[-1..-1].upcase }
  end
  alias titlecase titleize
end

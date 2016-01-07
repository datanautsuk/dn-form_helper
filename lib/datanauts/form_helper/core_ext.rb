class Symbol

  # :input.tag :name => 'address', :value => 'Foo Road'
  def tag(options={})
    option_string = (' ' + options.to_html_options).sub(/\s+$/, '')
    "<#{self.to_s}#{option_string} />"
  end

  # :div.wrap "Hello", :id => "userbox", :class => "box"
  # :div.wrap(:id => "userbox", :class => "box"){ "Hello" }
  #
  # If you give a content as block and as parameter too, then the parameter
  # will be the default value (in case of the block is empty)
  def wrap(content=nil, options={}, &block)
    (options = content; content = nil) if content.is_a? Hash
    content = yield || content if block
    option_string = (' ' + options.to_html_options).sub(/\s+$/, '')
    "<#{self.to_s}#{option_string}>#{content.to_s}</#{self.to_s}>\n"
  end
end

class Hash
  def to_html_options
    (self.map{|key, value| %(#{key.to_s}="#{value.to_s}") if value } - [nil]).join(" ")
  end
end

class String
  def underscore
    gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end
  
  def humanize
    self.gsub(/_id$/, "").gsub(/_/, " ").capitalize
  end
  
  def titleize
    underscore.humanize.gsub(/\b([a-z])/){|x| x[-1..-1].upcase}
  end
  alias_method :titlecase, :titleize
  
  # def html_safe
  #   self
  # end unless instance_methods.include? :html_safe

  # def html_safe?
  #   super rescue true
  # end 
  # unless instance_methods.include? "html_safe?".to_sym
  

end
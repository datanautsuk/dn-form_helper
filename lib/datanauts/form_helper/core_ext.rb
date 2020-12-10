# frozen_string_literal: true

require 'sequel/extensions/inflector'
require 'sequel/extensions/blank'

# Patches to allow easy(ish) html outpus
class Symbol
  # :input.tag :name => 'address', :value => 'Foo Road'
  def tag(options = {})
    "<#{self} #{options.to_html_options} />"
  end

  # :div.wrap "Hello", :id => "userbox", :class => "box"
  # :div.wrap(:id => "userbox", :class => "box"){ "Hello" }
  #
  # If you give a content as block and as parameter too, then the parameter
  # will be the default value (in case of the block is empty)
  def wrap(content = nil, options = {}, &block)
    if content.is_a? Hash
      options = content
      content = nil
    end

    content = yield || content if block
    "<#{self} #{options.to_html_options}>#{content}</#{self}>"
  end
end

# Useful extensions to hash class
class Hash
  def to_html_options
    compact.map do |k, v|
      v == true ? k.to_s : %(#{k}="#{v.to_s.tr('"', '%22')}")
    end.join ' '
  end

  def symbolize_keys
    transform_keys(&:to_sym)
  end

  def symbolize_keys!
    transform_keys!(&:to_sym)
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

# Overrides for Object
class Object
  def real_class
    if respond_to?('__getobj__')
      __getobj__.class
    else
      self.class
    end
  end

  def class_name
    real_class.name
  end

  def present?
    !blank?
  end
end

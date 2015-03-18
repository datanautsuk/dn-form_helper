$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'datanauts/form_helper'
require 'pry'

module Datanauts::FormHelper
  def capture_haml(*args, &block)
    yield args.first
  end
end

# def fake_model(name = 'model', errors_list = {})
#   model = double(name)
#   errors = double('errors')
  
#   allow(model).to receive(:new?) {false}
#   allow(model).to receive(:valid?) {errors_list.empty?}
  
#   allow(model).to  receive(:errors) {errors}
#   allow(errors).to receive(:on) {|field| errors_list[field]}
  
#   model
# end

class User
  
  def initialize(attrs = {})
    @attrs = attrs
    @required_fields = [:email]
  end
  
  def valid?
    e = errors
    @errors.empty?
  end
  
  def errors
    @errors ||= begin
      errors = {}
      @required_fields.each do |f|
        errors[f] = 'is missing' unless @attrs[f]
      end
      
      FakeErrors.new(errors)
    end    
  end
  
  def new?
    @attrs.length == 0
  end
  
  def method_missing(method, *args)
    super unless @attrs.member? method.to_sym
    
    @attrs[method.to_sym]
  end
  
end

class FakeErrors
  def initialize(errors)
    @errors = errors
  end
  
  
  
  def on(field)
    [@errors[field]] unless @errors[field].nil?
  end
  
  alias_method :[], :on
  
  # def [](field)
  #   [@errors[field]]
  # end
  
  def keys
    @errors.keys
  end
  
  def empty?
    @errors.empty?
  end
end
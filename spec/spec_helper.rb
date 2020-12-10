# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'dn-form_helper'
require 'pry'

RSpec.configure do |config|
  config.include Datanauts::FormHelper
end

module Datanauts
  module FormHelper
    def capture_haml(*args)
      yield args.first
    end

    def session
      {}
    end
  end
end

class User
  def initialize(attrs = {})
    @attrs = attrs
    @required_fields = [:email]
  end

  def valid?
    errors.empty?
  end

  def errors
    @errors ||= begin
      errors = {}
      @required_fields.each do |f|
        unless @attrs[f] || (respond_to?(f.to_sym) && send(f.to_sym))
          errors[f] = 'is missing'
        end
      end

      FakeErrors.new(errors)
    end
  end

  def pk
    @attrs[:id] || 1
  end

  def new?
    @attrs.empty?
  end

  def method_missing(method, *args)
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

  alias [] on

  # def [](field)
  #   [@errors[field]]
  # end

  def keys
    @errors.keys
  end

  def empty?
    @errors.empty?
  end

  def key?(name)
    keys.include?(name.to_sym)
  end
end

class String
  def no_white_space
    gsub(/\s*\n\s*/, '').chomp
  end

  def inspect
    self
  end
end

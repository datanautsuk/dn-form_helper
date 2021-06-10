# frozen_string_literal: true

require 'bigdecimal'
require 'rack/utils'

module Datanauts
  # ==========================================
  # = helper to generate html form for model
  # ==========================================
  module FormHelper
    def form_for(object, options = {}, &block)
      raise ArgumentError, 'Missing block' unless block_given?

      FormForPresenter.new(self, object, options.symbolize_keys, &block).to_html
    end

    def input(object, name, options = {})
      InputPresenter.new(object, name, options.symbolize_keys).to_html
    end
    alias text input

    def file_input(object, name, options = {})
      FileInputPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def datepicker(object, name, options = {})
      DatePickerPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def hidden(object, name, options = {})
      InputPresenter.new(object,
                         name,
                         options.symbolize_keys.merge(type: 'hidden')).to_html
    end

    def select(object, name, options = {})
      SelectPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def radio_group(object, name, options = {})
      RadioGroupPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def checkbox(object, name, options = {})
      CheckboxPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def switch(object, name, options = {})
      options[:class] = 'custom-control custom-switch'
      options[:switch] = true
      options[:hint_class] = 'd-block my-2'
      checkbox object, name, options
    end

    def checkbox_group(object, name, options = {})
      CheckboxGroupPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def textarea(object, name, options = {})
      TextAreaPresenter.new(object, name, options.symbolize_keys).to_html
    end

    def submit(object, value = nil, options = {})
      if value.is_a?(Hash)
        options = value
        value = nil
      end
      options.symbolize_keys!
      value ||= object.new? ? 'submit' : 'update'
      opts = options.dup.merge(value: value, type: 'submit')
      opts[:class] = 'btn btn-success' unless opts[:class]
      :input.tag(opts)
    end

    # Dummy class to hold the object and pass back to caller
    class FormModel
      def initialize(context, model_obj)
        @context = context
        @model   = model_obj
        @model.class.class_eval do
          attr_accessor :dn_required_fields, :dn_current_field_name
        end
        dummy_object = @model.real_class.new
        dummy_object.valid?
        @model.dn_required_fields = dummy_object.errors.keys
      end

      def fields_for(field_name)
        @model.dn_current_field_name = field_name
        yield self
        @model.dn_current_field_name = nil
      end

      def method_missing(meth, *args)
        return super unless @context.respond_to?(meth)

        @context.send(meth, @model, *args)
      end

      def respond_to_missing?(meth, *args)
        @context.respond_to?(meth) || super
      end
    end

    class << self
      attr_accessor :file_input_name_proc

      def configure
        yield self
      end
    end
  end
end

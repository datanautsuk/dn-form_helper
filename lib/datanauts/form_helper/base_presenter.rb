# frozen_string_literal: true

module Datanauts
  module FormHelper
    # base class for these presenters
    class BasePresenter
      attr_accessor :object, :name, :options

      def initialize(object, name, options = {})
        @object = object
        @name = name
        @options = options
      end

      private

      def field_id
        [
          singular_object_name,
          object.dn_current_field_name,
          name
        ].compact.join '_'
      end

      def input_name
        [
          singular_object_name,
          bracketed_field_prefix,
          bracketed_field_name
        ].compact.join
      end

      def singular_object_name
        object.class_name.underscore
      end

      def bracketed_field_prefix
        return unless object.dn_current_field_name.present?

        "[#{object.dn_current_field_name}]"
      end

      def bracketed_field_name
        "[#{name}]"
      end

      def current_value
        if object.dn_current_field_name.present?
          current_value_from_hash
        else
          object.send(name)
        end
      end

      def current_value_from_hash
        return unless field_object.is_a?(Hash)

        field_object[name.to_s] || field_object[name]
      end

      def field_object
        object.send(object.dn_current_field_name)
      end

      def tabindex
        tabindex_from_options = options.delete(:tab)
        return -1 if tabindex_from_options == false

        tabindex_from_options
      end

      def input_options_from_options
        @input_options_from_options ||= options.delete(:input_options) || {}
      end

      def required?
        options.delete(:required) || required_by_validation?
      end

      def required_by_validation?
        true if object.dn_required_fields.include?(name.to_sym)
      end
    end
  end
end

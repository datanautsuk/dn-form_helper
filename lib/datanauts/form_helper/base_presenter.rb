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
        name_from_options || name_from_table || object.class_name.underscore
      end

      def name_from_options
        @name_from_options ||= options.delete(:object_name)
      end

      def name_from_table
        return unless object.class.respond_to?(:table_name)

        object.class.table_name.to_s.singularize
      end

      def bracketed_field_prefix
        return unless object.dn_current_field_name.present?

        "[#{object.dn_current_field_name}]"
      end

      def bracketed_field_name
        "[#{name}]"
      end

      def value_to_use
        return supplied_value unless value_map?

        value_map[supplied_value]
      end

      def value_map?
        value_map.present?
      end

      def value_map
        return { true => '1', false => '0' } if boolean?

        @value_map ||= options.delete(:value_map) ||
                       options.delete(:mapped_values)
      end

      def boolean?
        @boolean ||= options.delete(:boolean)
      end

      def supplied_value
        @supplied_value ||= options.delete(:value) ||
                            input_options_from_options.delete(:value) ||
                            current_value
      end

      def current_value
        if object.dn_current_field_name.present?
          current_value_from_hash
        else
          @current_value ||= object.send(name)
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
        if options.key?(:required)
          # we only want to return true (or nil)
          true if options.delete(:required)
        else
          required_by_validation?
        end
      end

      def required_by_validation?
        # we only want to return true (or nil)
        true if object.dn_required_fields.include?(name.to_sym)
      end
    end
  end
end

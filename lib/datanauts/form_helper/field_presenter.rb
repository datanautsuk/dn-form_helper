# frozen_string_literal: true

module Datanauts
  module FormHelper
    # To present a field (bootstrap 4)
    class FieldPresenter < BasePresenter
      attr_accessor :input_html

      def initialize(object, name, input_html, options = {})
        @input_html = input_html
        super object, name, options
      end

      def to_html
        return input_html if options[:no_wrap]

        :div.wrap(label + field_input, remaining_options)
      end

      private

      def label
        return '' if label_from_options == false

        :label.wrap(label_caption, label_options)
      end

      def label_from_options
        @label_from_options ||= options.delete(:label)
      end

      def label_caption
        label_from_options || name.to_s.humanize.titleize
      end

      def label_options
        label_options_hash.merge(for: field_id)
      end

      def label_options_hash
        return {} unless options[:label_options].is_a?(Hash)

        options.delete(:label_options)
      end

      def field_input
        input_html + error_message + hint_html
      end

      def error_message
        return '' unless error?

        :div.wrap(object_error_message, class: 'invalid-feedback')
      end

      def error?
        object.errors&.keys&.include?(name)
      end

      def object_error_message
        object.errors[name].join ', '
      end

      def hint_html
        return '' unless hint.present?

        :small.wrap(hint, class: hint_class)
      end

      def hint
        @hint ||= options.delete(:hint)
      end

      def hint_class
        [
          'help-block',
          'text-muted',
          options.delete(:hint_class)
        ].compact.join(' ')
      end

      def remaining_options
        { class: wrapper_class }.merge(options)
      end

      def wrapper_class
        wrapper_classes.join(' ').strip
      end

      def wrapper_classes
        [
          class_from_options,
          standard_field_class,
          error_class,
          required_class
        ].compact
      end

      def class_from_options
        options.delete(:class)
      end

      def standard_field_class
        return if options.delete(:only_class)

        'form-group'
      end

      def error_class
        'has-error' if error?
      end

      def required_class
        'required' if object.dn_required_fields.include?(name)
      end
    end
  end
end

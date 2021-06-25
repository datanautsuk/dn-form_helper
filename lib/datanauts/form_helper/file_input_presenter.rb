# frozen_string_literal: true

# .custom-file
#   %input#customFile.custom-file-input{type: 'file', name: 'import[file]', value: (@import ? @import.file : nil)}/
#   %label.custom-file-label{:for => "customFile"} Choose file

module Datanauts
  module FormHelper
    # Class to present <input type="file"> element
    class FileInputPresenter < BasePresenter
      attr_accessor :object, :name, :options

      def initialize(object, name, options)
        @object = object
        @name = name
        @options = options
      end

      def to_html
        # NB we use the argument rather than the block so that the attributes
        # from options are removed before being passed to the enclosing div
        # :div.wrap(hint_html + file_input_html, remaining_options)
        presented_file_field.to_html
      end

      private

      def presented_file_field
        FieldPresenter.new(object, name, file_input_html, final_options)
      end

      def file_input_html
        input_tag_html + label_html
      end

      def input_tag_html
        :input.tag(input_options)
      end

      def input_options
        {
          id: field_id,
          class: input_class,
          type: 'file',
          name: input_name,
          required: required?
        }.merge(other_input_options).compact
      end

      def input_class
        input_classes.compact.join(' ')
      end

      def other_input_options
        {
          tabindex: tabindex,
          autocomplete: autocomplete
        }.merge(input_options_from_options)
      end

      def autocomplete
        options.delete(:autocomplete)
      end

      def input_classes
        ['custom-file-input', input_options_class, error_class].compact
      end

      def input_options_class
        input_options_from_options.delete(:class)
      end

      def error_class
        'is-invalid' if object.errors.key?(name)
      end

      # %label.custom-file-label{:for => "customFile"} Choose file
      def label_html
        :label.wrap(label_value, label_options)
      end

      def label_value
        existing_file_label || label_from_options || default_label
      end

      # file uploads may work in several ways
      # we need to have a file_input_name_proc defined
      # in order to retrieve this
      def existing_file_label
        return unless current_value.present?
        return default_existing_label unless input_field_proc.present?

        "#{existing_file_name} (click to change)"
      end

      def input_field_proc
        Datanauts::FormHelper.file_input_name_proc
      end

      def default_existing_label
        "[#{name} saved] (click to change)"
      end

      def existing_file_name
        input_field_proc.call(current_value)
      end

      def label_from_options
        options.delete(:label)
      end

      def default_label
        '(choose file)'
      end

      def label_options
        {
          class: 'custom-file-label fileinput-filename',
          for: field_id
        }
      end

      def final_options
        options.merge(field_options)
      end

      def field_options
        {
          label: false,
          class: 'custom-file',
          only_class: true,
          'data-provides': 'fileinput'
        }
      end
    end
  end
end

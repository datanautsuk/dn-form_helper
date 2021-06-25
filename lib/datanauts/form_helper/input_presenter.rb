# frozen_string_literal: true

module Datanauts
  module FormHelper
    # rubocop:disable Metrics/ClassLength
    # Class to present <input> element
    class InputPresenter < BasePresenter
      def to_html
        if options[:type].to_s == 'hidden'
          options[:label] = false
          options[:no_wrap] = true
        end

        options[:type] = 'password' if name =~ /password/

        FieldPresenter.new(object, name, input_html, options).to_html
      end

      private

      def input_html
        return input_group_html if input_group?

        input_tag_html
      end

      def input_tag_html
        :input.tag(input_options)
      end

      def input_group?
        prefix.present? || suffix.present?
      end

      def prefix
        @prefix ||= options.delete(:prefix) || options.delete(:prepend)
      end

      def suffix
        @suffix ||= options.delete(:suffix) || options.delete(:append)
      end

      def input_group_html
        :div.wrap(class: input_group_class) do
          prefix_html + input_tag_html + suffix_html
        end
      end

      def prefix_html
        return '' unless prefix.present?

        :div.wrap(class: 'input-group-prepend') do
          :div.wrap(class: 'input-group-text') { prefix }
        end
      end

      def suffix_html
        return '' unless suffix.present?

        :div.wrap(class: 'input-group-append') do
          :div.wrap(class: 'input-group-text') { suffix }
        end
      end

      def input_group_class
        ['input-group', options.delete(:input_group_class)].compact.join(' ')
      end

      def input_options
        {
          id: field_id,
          class: input_class,
          type: input_type,
          name: input_name,
          value: input_value,
          required: required?
        }.merge(other_input_options).compact
      end

      def input_class
        input_classes.compact.join(' ')
      end

      def input_type
        options.delete(:type) || 'text'
      end

      def input_value
        case value_to_use.class
        when BigDecimal
          value_to_use.to_f
        when Array
          safe_joined_array_vals
        when String
          Rack::Utils.escape_html(value_to_use)
        else
          value_to_use
        end
      end

      def safe_joined_array_vals
        value_to_use.map { |v| Rack::Utils.escape_html(v) }.join ','
      end

      def other_input_options
        {
          tabindex: tabindex,
          placeholder: placeholder,
          style: style,
          autocomplete: autocomplete,
        }.merge(input_options_from_options)
      end

      def placeholder
        options.delete(:placeholder)
      end

      def style
        options.delete(:style)
      end

      def autocomplete
        options.delete(:autocomplete)
      end

      def input_classes
        ['form-control', input_options_class, error_class].compact
      end

      def input_options_class
        input_options_from_options.delete(:class)
      end

      def error_class
        'is-invalid' if object.errors.key?(name)
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end

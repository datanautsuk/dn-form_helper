# frozen_string_literal: true

module Datanauts
  module FormHelper
    # Class to present <input> element
    class CheckboxGroupPresenter < BasePresenter
      def to_html
        FieldPresenter.new(object, name, boxes_html, remaining_opts).to_html
      end

      private

      def boxes_html
        empty_checkbox + checkboxes_html
      end

      def empty_checkbox
        return unless empty_checkbox?

        :input.tag(type: 'hidden', name: checkbox_name, id: "#{field_id}_empty")
      end

      def empty_checkbox?
        options.delete(:include_empty) || options.delete(:include_blank)
      end

      def checkbox_name
        "#{input_name}[]"
      end

      def checkboxes_html
        presented_options.map(&:to_html).join
      end

      def presented_options
        options.delete(:options).map do |option_value|
          CheckboxOptionPresenter.new(option_value,
                                      current_value,
                                      option_presenter_options)
        end
      end

      def option_presenter_options
        @option_presenter_options ||= {
          wrapper_class: wrapper_class,
          div_options: options.delete(:div_options),
          name: checkbox_name,
          id_stem: field_id,
          selected: options.delete(:selected),
          checkbox_options: (options.delete(:input_options) || {}),
          value_options: (options.delete(:value_options) || {}),
          custom: custom?
        }
      end

      def wrapper_class
        return custom_wrapper_class if custom?

        ['form-check', inline_class].compact.join ' '
      end

      def custom?
        @custom ||= options.delete(:custom)
      end

      def custom_wrapper_class
        ['custom-control', 'custom-checkbox', custom_inline_class].compact.join ' '
      end

      def custom_inline_class
        'custom-control-inline' if inline?
      end

      def inline?
        @inline ||= options.delete(:inline)
      end

      def inline_class
        'form-check-inline' if inline?
      end

      def remaining_opts
        options.merge(modified_options.compact)
      end

      def modified_options
        {
          label_options: { class: 'd-block mb-2' },
          hint_class: hint_class
        }
      end

      def hint_class
        return unless inline?

        [options.delete(:hint_class), 'd-block', 'my-2'].compact.join(' ')
      end
    end

    # present individual option
    class CheckboxOptionPresenter
      attr_accessor :option_value, :label_text, :actual_value, :options

      def initialize(option_value, actual_value, options = {})
        @option_value, @label_text = option_value
        @label_text ||= option_value
        @actual_value = actual_value
        @options = options
      end

      def to_html
        :div.wrap(wrapper_attributes) do
          input_tag + label_tag
        end
      end

      private

      def wrapper_attributes
        { class: options[:wrapper_class] }.merge(div_options)
      end

      def div_options
        options[:div_options] || {}
      end

      def input_tag
        :input.tag(input_attrs.compact)
      end

      def input_attrs
        {
          class: input_class,
          id: checkbox_id,
          name: options[:name],
          type: 'checkbox',
          value: option_value,
          checked: checked
        }.merge(checkbox_options).merge(value_options)
      end

      def input_class
        [class_stem, 'input'].join '-'
      end

      def class_stem
        return 'custom-control' if custom?

        'form-check'
      end

      def custom?
        options[:custom]
      end

      def checkbox_id
        [options[:id_stem], safe_value].join '_'
      end

      def safe_value
        option_value.to_s.downcase.gsub(/\W/, '-')
      end

      def checked
        'checked' if value_match? || value_in_array? || selected_value?
      end

      def value_match?
        option_value == actual_value
      end

      def value_in_array?
        return unless actual_value.is_a?(Array)

        actual_value.include?(option_value)
      end

      def selected_value?
        return unless actual_value.nil?

        options[:selected] == option_value
      end

      def checkbox_options
        return {} unless possible_options.is_a?(Hash)

        possible_options
      end

      def possible_options
        options[:checkbox_options] || options[:input_options]
      end

      def value_options
        return {} unless options[:value_options].is_a?(Hash)
        return {} unless options[:value_options][option_value].is_a?(Hash)

        options[:value_options][option_value]
      end

      def label_tag
        :label.wrap(label_attrs) { label_text }
      end

      def label_attrs
        {
          class: "#{class_stem}-label",
          for: checkbox_id
        }
      end
    end
  end
end

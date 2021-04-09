# frozen_string_literal: true

module Datanauts
  module FormHelper
    # Class to present <input> element
    class RadioGroupPresenter < BasePresenter
      def to_html
        FieldPresenter.new(object, name, radios_html, remaining_opts).to_html
      end

      private

      def radios_html
        presented_radios.map(&:to_html).join
      end

      def presented_radios
        options.delete(:options).map do |option_value|
          RadioOptionPresenter.new(option_value,
                                   current_value,
                                   option_presenter_options)
        end
      end

      def option_presenter_options
        @option_presenter_options ||= {
          wrapper_class: wrapper_class,
          name: input_name,
          id_stem: field_id,
          selected: options.delete(:selected)
        }
      end

      def wrapper_class
        ['form-check', inline_class].compact.join ' '
      end

      def inline_class
        'form-check-inline' if inline?
      end

      def inline?
        @inline ||= options.delete(:inline)
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

        [options.delete(:hint_class), 'd-block'].compact.join(' ')
      end
    end

    # To present each radio option
    class RadioOptionPresenter
      attr_accessor :option_value, :label_text, :actual_value, :options

      def initialize(option_value, actual_value, options = {})
        @option_value, @label_text = option_value
        @label_text ||= option_value
        @actual_value = actual_value
        @options = options
      end

      def to_html
        :div.wrap(class: options[:wrapper_class]) do
          input_tag + label_tag
        end
      end

      private

      def input_tag
        :input.tag(input_attrs.compact)
      end

      def input_attrs
        {
          class: 'form-check-input',
          id: radio_id,
          name: options[:name],
          type: 'radio',
          value: option_value,
          checked: checked
        }.merge(radio_options).merge(value_options)
      end

      def radio_id
        [options[:id_stem], safe_value].join '_'
      end

      def safe_value
        option_value.to_s.downcase.gsub(/\W/, '-')
      end

      def checked
        'checked' if value_match? || selected_value?
      end

      def value_match?
        option_value == actual_value
      end

      def selected_value?
        return unless actual_value.nil?

        options[:selected] == option_value
      end

      def radio_options
        return {} unless possible_options.is_a?(Hash)

        possible_options
      end

      def possible_options
        options[:radio_options] || options[:input_options]
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
          class: 'form-check-label',
          for: radio_id
        }
      end
    end
  end
end

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
        'checked' if option_value == selected_value
      end

      def selected_value
        options[:selected] || actual_value
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
          for: checkbox_id
        }
      end
    end
  end
end

def radio_group(object, name, options = {})
  options.symbolize_keys!

  radio_id = "#{object.class_name}_#{name}".underscore
  radio_name = make_name(object, name, options)

  wrapper_class = 'radio form-check'
  if options.delete(:inline)
    wrapper_class << ' form-check-inline'
    options[:hint_class] = [
      options.delete(:hint_class),
      'd-block'
    ].compact.join(' ')
  end

  selected = options.delete(:selected) || dn_form_helper_value(object, name)

  radios_html = options.delete(:options).inject('') do |html_string, op|
    val, label = op
    label ||= val
    selected_attr = if selected == val
                      { checked: 'checked' }
                    else
                      {}
                    end

    input_radio_id = "#{radio_id}_#{val.to_s.gsub(/\s/, '_')}"
    input_attrs = {
      class: 'form-check-input',
      id: input_radio_id,
      name: radio_name,
      type: 'radio',
      value: val
    }.merge(selected_attr)

    input_tag = :input.tag(input_attrs)
    label_tag = :label.wrap(class: 'form-check-label',
                            for: input_radio_id) { label.to_s }

    html_string + :div.wrap(class: wrapper_class) do
      input_tag + label_tag
    end
  end

  if options.delete(:no_wrap)
    radios_html
  else
    field_for object,
              name,
              radios_html,
              options.merge(label_options: { class: 'd-block mb-2' })
  end
end

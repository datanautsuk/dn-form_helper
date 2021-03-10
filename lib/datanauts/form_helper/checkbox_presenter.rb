# frozen_string_literal: true

#  ============
#  = Checkbox =
#  ============

# Standard...
# <div class="form-check">
#   <input class="form-check-input" type="checkbox" value="" id="defaultCheck1">
#   <label class="form-check-label" for="defaultCheck1">
#     Default checkbox
#   </label>
# </div>

# Switch
# <div class="custom-control custom-switch">
#   <input type="checkbox" class="custom-control-input" id="customSwitch1">
#   <label class="custom-control-label" for="customSwitch1">
#     Toggle this switch element
#   </label>
# </div>

module Datanauts
  module FormHelper
    # Class to present <input> element
    class CheckboxPresenter < BasePresenter
      def to_html
        FieldPresenter.new(object, name, checkbox_html, remaining_opts).to_html
      end

      private

      def checkbox_html
        hidden_option + checkbox_option + label
      end

      def hidden_option
        :input.tag(hidden_checkbox_options)
      end

      def hidden_checkbox_options
        {
          type: 'hidden',
          name: input_name,
          id: "#{field_id}_false",
          value: '0'
        }
      end

      def checkbox_option
        :input.tag(checkbox_options.compact)
      end

      def checkbox_options
        {
          type: 'checkbox',
          name: input_name,
          id: "#{field_id}_true",
          value: 1,
          tabindex: tabindex,
          checked: ('checked' if current_value || options.delete(:checked)),
          class: switch? ? 'custom-control-input' : 'form-check-input'
        }.merge(input_options_from_options)
      end

      def switch?
        @switch ||= options.delete(:switch)
      end

      def label
        :label.wrap(label_options) do
          options.delete(:label) || name.to_s.humanize.titleize
        end
      end

      def label_options
        {
          for: "#{field_id}_true",
          class: label_class
        }
      end

      def label_class
        switch? ? 'custom-control-label' : 'form-check-label'
      end

      def remaining_opts
        options[:label] = false
        wrapper_div_options.merge(options)
      end

      def wrapper_div_options
        return { class: 'form-check', only_class: true } unless switch?

        { class: 'custom-control custom-switch', only_class: true }
      end
    end
  end
end

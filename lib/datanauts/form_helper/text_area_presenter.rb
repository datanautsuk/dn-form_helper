# frozen_string_literal: true

module Datanauts
  module FormHelper
    # Class to present <textarea> element
    class TextAreaPresenter < BasePresenter
      def to_html
        FieldPresenter.new(object, name, text_area_html, options).to_html
      end

      private

      def text_area_html
        :textarea.wrap(text_area_value, text_area_options)
      end

      def text_area_value
        Rack::Utils.escape_html(current_value)
      end

      def text_area_options
        {
          id: field_id,
          class: 'form-control',
          name: input_name,
          rows: options.delete(:rows),
          cols: options.delete(:cols),
          tabindex: tabindex,
          required: required?
        }.merge(other_options)
      end

      def other_options
        options.delete(:input_options) || {}
      end
    end
  end
end

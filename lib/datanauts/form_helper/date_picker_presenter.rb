# frozen_string_literal: true

module Datanauts
  module FormHelper
    # Class to present <input> element
    class DatePickerPresenter < BasePresenter
      def to_html
        InputPresenter.new(object, name, updated_options).to_html
      end

      private

      def updated_options
        { input_options: new_input_options }.merge(options_with_date_value)
      end

      def new_input_options
        (options.delete(:input_options) || {}).merge(datepicker_options)
      end

      def datepicker_options
        datepicker_attribute_options.merge('data-provide': 'datepicker')
      end

      def datepicker_attribute_options
        new_date_picker_options.transform_keys! { |key| "data-date-#{key}" }
      end

      def new_date_picker_options
        {
          format: options.delete(:format),
          startDate: options.delete(:startDate) || options.delete(:start),
          endDate: options.delete(:endDate) || options.delete(:end)
        }.merge(supplied_date_picker_options)
      end

      def supplied_date_picker_options
        options.delete(:datepicker_options) || {}
      end

      def options_with_date_value
        options.merge(value: display_date_value)
      end

      def display_date_value
        return unless current_value.present?

        current_value.strftime(display_format)
      end

      def display_format
        display_format_from_options || '%d %b %Y'
      end

      def display_format_from_options
        options.delete(:rformat) || options.delete(:display_format)
      end
    end
  end
end

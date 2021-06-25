# frozen_string_literal: true

module Datanauts
  module FormHelper
    # Class to present <select> element
    # rubocop:disable Metrics/ClassLength
    class SelectPresenter < BasePresenter
      def to_html
        FieldPresenter.new(object, name, select_html, remaining_opts).to_html
      end

      private

      def select_html
        return input_group_html if input_group?

        select_tag_html
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
          prefix_html + select_tag_html + suffix_html
        end
      end

      def input_group_class
        ['input-group', options.delete(:input_group_class)].compact.join(' ')
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

      def select_tag_html
        :select.wrap(select_attrs) { prompt_option + options_html }
      end

      def select_attrs
        {
          name: select_name,
          id: field_id,
          class: input_class,
          tabindex: tabindex,
          multiple: multiple?,
          required: required?
        }.compact.merge(input_options_from_options)
      end

      def input_class
        input_classes.reject(&:blank?).compact.join(' ')
      end

      def input_classes
        # options[:class] is there for being lazy (and backwards compatability)
        # if supplied it will go on both the select box and the surrounding div
        ['form-control', options[:class], input_options_class, error_class]
      end

      def input_options_class
        input_options_from_options.delete(:class)
      end

      def error_class
        'is-invalid' if object.errors.key?(name)
      end

      def select_name
        return input_name unless multiple?

        "#{input_name}[]"
      end

      def multiple?
        @multiple ||= options.delete(:multiple)
      end

      def prompt_option
        return '' if prompt == false

        :option.wrap(value: '') { prompt || 'choose...' }
      end

      def prompt
        @prompt ||= options.delete(:prompt)
      end

      def options_html
        return grouped_options_html if group?

        presented_options.map(&:to_html).join ''
      end

      def group?
        group.present?
      end

      def group
        @group ||= options.delete(:group)
      end

      def grouped_options_html
        grouped_options.map do |group_name, group_options|
          OptionGroupPresenter.new(group_name,
                                   value_field.to_sym,
                                   text_field.to_sym,
                                   current_value,
                                   group_options).to_html
        end.join ''
      end

      def grouped_options
        grouped_options_from_options.group_by { |opt| opt.send(group.to_sym) }
      end

      def grouped_options_from_options
        return group_options_from_array if options[:options].is_a?(Array)

        group_options_from_table
      end

      def group_options_from_array
        options.delete(:options).map { |data| OpenStruct.new(data) }
      end

      def group_options_from_table
        options.delete(:options).all
      rescue StandardError
        []
      end

      def presented_options
        select_options.map do |option_value|
          OptionPresenter.new(option_value, option_presenter_options)
        end
      end

      def select_options
        case options[:options]
        when Hash
          options_from_hash
        when Array
          options.delete(:options)
        else
          options_from_table
        end
      end

      def options_from_hash
        options.delete(:options).to_a
      end

      def options_from_table
        options.delete(:options).select_hash(value_field.to_sym,
                                             text_field.to_sym).to_a
      rescue StandardError
        []
      end

      def value_field
        options.delete(:options_id) || 'id'
      end

      def text_field
        options.delete(:options_name) || 'name'
      end

      def option_presenter_options
        @option_presenter_options ||= {
          selected: options.delete(:selected) || current_value
        }
      end

      def remaining_opts
        modified_options.compact.merge(options)
      end

      def modified_options
        { class: wrapper_class }
      end

      def wrapper_class
        return if wrapper_classes.empty?

        wrapper_classes.compact.join ' '
      end

      def wrapper_classes
        @wrapper_classes ||= [
          options.delete(:wrapper_class),
          options.delete(:class)
        ]
      end
    end
    # rubocop:enable Metrics/ClassLength

    # class to present <optgroup> tags
    class OptionGroupPresenter
      attr_accessor :name, :val_meth, :lbl_meth, :actual_value, :options

      def initialize(name, val_meth, lbl_meth, actual_value, options)
        @name = name
        @val_meth = val_meth
        @lbl_meth = lbl_meth
        @actual_value = actual_value
        @options = options
      end

      def to_html
        :optgroup.wrap(label: name) { options_html }
      end

      private

      def options_html
        presented_options.map(&:to_html).join('')
      end

      def presented_options
        options.map do |option|
          OptionPresenter.new(value_and_label(option), actual_value)
        end
      end

      def value_and_label(opt)
        val = opt.respond_to?(val_meth) ? opt.send(val_meth) : opt[val_meth]
        label = opt.respond_to?(lbl_meth) ? opt.send(lbl_meth) : opt[lbl_meth]
        [val, label]
      end
    end

    # class to present <option> tags
    class OptionPresenter
      attr_accessor :option_value, :actual_value, :label_text

      def initialize(option_value, params)
        @option_value, @label_text = option_value
        @label_text ||= option_value.humanize
        @actual_value = params[:selected]
      end

      def to_html
        :option.wrap(option_attributes.compact) { label_text }
      end

      def option_attributes
        {
          value: option_value,
          selected: selected?
        }
      end

      def selected?
        return unless actual_value.present?
        return in_array? if actual_value.is_a?(Array)

        true if actual_value.to_s == option_value.to_s
      end

      def in_array?
        true if actual_value.map(&:to_s).include?(option_value)
      end
    end
  end
end

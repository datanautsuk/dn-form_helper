# frozen_string_literal: true

module Datanauts
  module FormHelper
    # The main form for presenter
    class FormForPresenter
      attr_accessor :context, :object, :parent, :options, :block

      def initialize(context, object, options, &block)
        @context = context
        @object, @parent = [*object]
        @options = options
        @block = block
      end

      def to_html
        :form.wrap(content, form_attrs)
      end

      private

      def content
        method_field + csrf_field + content_from_block
      end

      def method_field
        return '' if object.new?
        return '' if explicit_post_request?

        :input.tag(type: 'hidden', name: '_method', value: 'put')
      end

      def explicit_post_request?
        options[:method].to_s.downcase == 'post'
      end

      def csrf_field
        return '' unless csrf_value.present?

        :input.tag(type: 'hidden',
                   name: 'authenticity_token',
                   value: csrf_value)
      end

      def csrf_value
        return unless context.session

        context.session[:csrf]
      end

      def content_from_block
        context.capture_haml(FormModel.new(context, object), &block)
      end

      def form_attrs
        derived_form_attrs.compact.merge(options)
      end

      def derived_form_attrs
        {
          method: :post,
          action: action,
          enctype: enctype,
          class: form_class
        }
      end

      def action
        action_from_options || derived_action
      end

      def action_from_options
        options[:action]
      end

      def derived_action
        script_base + prefix + resources_path + resource_path
      end

      def script_base
        context.request.script_name.gsub(/\/$/, '')
      end

      def prefix
        return '' unless parent.present?

        "/#{parent.class_name.tableize}/#{parent.id}"
      end

      def resources_path
        "/#{object.class_name.tableize}"
      end

      def resource_path
        return '' if object.new?

        "/#{object.pk}"
      end

      def enctype
        'multipart/form-data' if options.delete(:file)
      end

      def form_class
        form_classes.compact.join ' '
      end

      def form_classes
        ['form', options.delete(:class), error_class]
      end

      def error_class
        return unless object.respond_to?(:errors)

        'was-validated' unless object.errors.empty?
      end
    end
  end
end

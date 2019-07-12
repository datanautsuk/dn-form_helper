require 'datanauts/form_helper/version'
require 'datanauts/form_helper/core_ext'
require 'bigdecimal'
require 'rack/utils'

module Datanauts
  module FormHelper
    # ==========================================
    # = helper to generate html form for model
    # =
    # ==========================================
    def form_for(object, options = {}, &block)
      options.symbolize_keys!

      raise ArgumentError, 'Missing block' unless block_given?

      object, parent_object = [*object]
      prefix = if parent_object
                 "/#{parent_object.class_name.underscore.pluralize}/#{parent_object.id}"
               else
                 ''
               end

      opts = { method: :post }

      mfield = object.new? ? '' : :input.tag(type: 'hidden', name: '_method', value: 'put')
      csrf_field = session && session[:csrf] ? :input.tag(type: 'hidden', name: 'authenticity_token', value: session[:csrf]) : ''

      if (options[:action].nil? || options[:action] == '') && defined?(request)
        if object.new?
          opts[:action] = request.script_name.gsub(/\/$/, '') + prefix + "/#{object.class_name.underscore}s"
        else
          opts[:action] = request.script_name.gsub(/\/$/, '') + prefix + "/#{object.class_name.underscore}s/#{object.pk}"
        end
      end

      options[:enctype] = 'multipart/form-data' if options.delete(:file)

      :form.wrap(opts.merge(options)) { mfield + csrf_field + capture_haml(FormModel.new(self, object), &block) }
    end

    # =========
    # = Input =
    # =========

    def input(object, name, options = {})
      options.symbolize_keys!

      input_id = "#{object.class_name}_#{name}".underscore
      input_name = make_name(object, name, options)

      # get object value
      val = if options.key? :value
              options[:value]
            else
              begin
                dn_form_helper_value(object, name)
              rescue
                nil
              end
            end

      if val.is_a? BigDecimal
        # if the field appears to be for currency, format it to 2 decimal places.
        val = if options[:type] == :currency
                format('%0.2f', val)
              else
                val.to_f
              end
      end

      val = val.join(',') if val.is_a? Array
      val = options.delete(:value) || val
      val = Rack::Utils.escape_html(val) if val.is_a? String

      if options[:type].to_s == 'hidden'
        options[:label] = false
        options[:no_wrap] = true if options[:no_wrap].nil?
      end

      options[:type] = 'password' if name =~ /password/

      tabindex = options.delete(:tab)
      tabindex = -1 if tabindex == false
      input_options = options.delete(:input_options) || {}
      input_classes = ['form-control'] << input_options.delete(:class)

      input_options = {
        id: input_id,
        class: input_classes.compact.join(' '),
        type: options.delete(:type) || 'text',
        name: input_name,
        tabindex: tabindex,
        placeholder: options.delete(:placeholder),
        value: val,
        style: options.delete(:style),
        autocomplete: options.delete(:autocomplete)
      }.merge(input_options)

      input_tag_html = :input.tag(input_options)

      prepend = options.delete(:prepend)

      if prepend
        prepend = :div.wrap(class: 'input-group-prepend') do
          :div.wrap(class: 'input-group-text') { prepend }
        end
      end

      if append = options.delete(:append)
        append = :div.wrap(class: 'input-group-addon') { append }
      end

      if prepend || append
        input_tag_html = :div.wrap(class: 'input-group') { prepend.to_s + input_tag_html + append.to_s }
      end

      if options.delete(:no_wrap)
        input_tag_html
      else
        field_for object, name, input_tag_html, options
      end
    end

    def datepicker(object, name, options = {})
      options.symbolize_keys!
      datepicker_options = {
        format: options.delete(:format),
        startDate: options.delete(:startDate) || options.delete(:start),
        endDate: options.delete(:endDate) || options.delete(:end)
      }
      datepicker_options.merge!(options.delete(:datepicker_options) || {})
      datepicker_options.transform_keys! { |k| "data-date-#{k}" }
      datepicker_options['data-provide'] = 'datepicker'
      input_options = options.delete(:input_options) || {}
      options[:input_options] = input_options.merge(datepicker_options)

      ruby_format = options.delete(:rformat) || '%d %b %Y'
      val = dn_form_helper_value(object, name)
      options[:value] = val.strftime(ruby_format) unless val.nil?
      input object, name, options
    end

    #  ==========
    #  = Hidden =
    #  ==========

    def hidden(object, name, options = {})
      input object, name, options.merge(type: 'hidden')
    end

    #  ==========
    #  = Select =
    #  ==========

    def select(object, name, options = {})
      options.symbolize_keys!

      select_id = "#{object.class_name}_#{name}".underscore
      select_name = make_name(object, name, options)

      multiple = options.delete(:multiple)
      select_name << '[]' if multiple

      options_html = ''
      if prompt = options.delete(:prompt)
        options_html = :option.wrap(value: '') { prompt }
      elsif prompt.nil?
        options_html = :option.wrap(value: '') { 'Choose' }
      end

      tabindex = options.delete(:tab)
      tabindex = -1 if tabindex == false
      input_classes = ['form-control'] << options.delete(:class)

      options[:class] = options.delete(:wrapper_class)

      select_options = {
        id: select_id,
        class: input_classes.compact.join(' '),
        name: select_name,
        tabindex: tabindex,
        multiple: multiple
      }.compact.merge(options.delete(:input_options) || {})

      selected = dn_form_helper_value(object, name)
      selected = options.delete(:selected) || selected

      options[:options] = options[:options].to_a if options[:options].is_a? Hash

      unless options[:options].is_a? Array
        options[:options] = options_for_select(options[:options], value_field: options.delete(:options_id),
                                                                  text_field: options.delete(:options_name))
      end

      option_attributes = options.delete(:option_attributes) || {}

      select_html = :select.wrap(select_options) do
        options_html + options.delete(:options).inject('') do |s, op|
          val, text = op.is_a?(Array) ? [op[0], op[1]] : [op, op.humanize]
          option_attr = option_attributes.each_with_object({}) { |p, h| h[p[0]] = p[1][val]; }
          is_selected = if selected.is_a?(Array)
                          'selected' if val && selected.map(&:to_s).include?(val.to_s)
                        else
                          'selected' if val && selected.to_s == val.to_s
                        end

          s += :option.wrap({
            value: val,
            selected: is_selected
          }.merge(option_attr)) { text }
        end
      end

      if prepend = options.delete(:prepend)
        prepend = :div.wrap(class: 'input-group-addon') { prepend }
      end

      if append = options.delete(:append)
        append = :div.wrap(class: 'input-group-addon') { append }
      end

      if prepend || append
        select_html = :div.wrap(class: 'input-group') { prepend.to_s + select_html + append.to_s }
      end

      if options.delete(:no_wrap)
        select_html
      else
        field_for object, name, select_html, options
      end
    end

    #  =========
    #  = Radio =
    #  =========

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
    #   <label class="custom-control-label" for="customSwitch1">Toggle this switch element</label>
    # </div>

    def checkbox(object, name, options = {})
      options.symbolize_keys!

      checkbox_id = "#{object.class_name}_#{name}".underscore
      checkbox_name = make_name(object, name, options)
      val = dn_form_helper_value(object, name)

      tabindex = options.delete(:tab)
      tabindex = -1 if tabindex == false

      switch = options.delete(:switch)

      # hidden "false" option...
      h = {
        type: 'hidden',
        name: checkbox_name,
        id: "#{checkbox_id}_false",
        value: 0,
        tabindex: tabindex
      }
      checkbox_html = :input.tag(h)

      o = {
        type: 'checkbox',
        name: checkbox_name,
        id: "#{checkbox_id}_true",
        value: 1,
        class: switch ? 'custom-control-input' : 'form-check-input'
      }
      o.update(checked: 'checked') if val || options[:checked] == 'checked'
      checkbox_html += :input.tag(o)

      # label...
      l = {
        for: "#{checkbox_id}_true",
        class: switch ? 'custom-control-label' : 'form-check-label'
      }
      checkbox_html += :label.wrap(l) do
        options.delete(:label) || name.to_s.humanize.titleize
      end

      options[:class] ||= 'form-check'

      field_for object, name, checkbox_html, options.merge(label: false)
    end

    def switch(object, name, options = {})
      options[:class] = 'custom-control custom-switch'
      options[:switch] = true
      checkbox object, name, options
    end

    def checkbox_group(object, name, options = {})
      options.symbolize_keys!

      checkbox_id = "#{object.class_name}_#{name}".underscore
      checkbox_name = "#{object.class_name.underscore}[#{name}][]"

      div_options = {}.merge(options.delete(:div_options) || {})
      checkbox_options = {}.merge(options.delete(:input_options) || {})

      value_options = options.delete(:value_options) || {}

      checkboxes_html = :input.tag(type: 'hidden',
                                   name: checkbox_name,
                                   id: "#{checkbox_id}_empty")

      wrapper_class = 'checkbox form-check'
      if options.delete(:inline)
        wrapper_class << ' form-check-inline'
        options[:hint_class] = [
          options.delete(:hint_class),
          'd-block'
        ].compact.join(' ')
      end

      checkboxes_html += options.delete(:options).inject('') do |html_string, op|
        val, label = op
        label ||= val
        selected_attr = {}
        selected = options.delete(:selected)

        if dn_form_helper_value(object, name) == val
          selected_attr = { checked: 'checked' }
        elsif dn_form_helper_value(object, name).is_a?(Array) && dn_form_helper_value(object, name).include?(val)
          selected_attr = { checked: 'checked' }
        elsif dn_form_helper_value(object, name).nil? && selected == val
          selected_attr = { checked: 'checked' }
        end

        input_checkbox_id = "#{checkbox_id}_#{val.to_s.gsub(/\s/, '_')}"
        input_attrs = {
          class: 'form-check-input',
          id: input_checkbox_id,
          name: checkbox_name,
          type: 'checkbox',
          value: val
        }.merge(selected_attr).merge(checkbox_options).merge(value_options[val] || {})

        input_tag = :input.tag(input_attrs)
        label_tag = :label.wrap(class: 'form-check-label',
                                for: input_checkbox_id) { label.to_s }

        html_string + :div.wrap({ class: wrapper_class }.merge(div_options)) do
          input_tag + label_tag
        end
      end

      if options.delete(:no_wrap)
        checkboxes_html
      else
        field_for object,
                  name,
                  checkboxes_html,
                  options.merge(label_options: { class: 'd-block mb-2' })
      end
    end

    #  ============
    #  = Textarea =
    #  ============

    def textarea(object, name, options = {})
      options.symbolize_keys!
      textarea_id = "#{object.class_name}_#{name}".underscore
      textarea_name = make_name(object, name, options)
      val = dn_form_helper_value(object, name)

      tabindex = options.delete(:tab)
      tabindex = -1 if tabindex === false

      textarea_options = {
        id: textarea_id,
        class: 'form-control',
        name: textarea_name,
        rows: options.delete(:rows),
        cols: options.delete(:cols),
        tabindex: tabindex
      }.merge(options.delete(:input_options) || {})

      val = Rack::Utils.escape_html(val) if val.is_a? String

      textarea_html = :textarea.wrap(textarea_options) { val }

      field_for object, name, textarea_html, options.merge(input_id: textarea_id)
    end

    # =================
    # = Submit button =
    # =================

    def submit(object, value = nil, options = {})
      options.symbolize_keys!
      value = object.new? ? 'submit' : 'update' unless value
      opts = options.dup.merge(value: value, type: 'submit')
      opts[:class] = 'btn btn-default' unless opts[:class]
      :input.wrap(opts)
    end

    #  =================
    #  = Field wrapper =
    #  =================

    def field_for(object, name, input_html, options = {})
      field_id = "#{object.class_name}_#{name}".underscore
      o = object.real_class.new
      o.valid?
      required_fields = o.errors.keys

      err = object.errors.keys.include?(name) ? object.errors[name] : nil
      has_error = !err.nil? && ![*err].empty?

      option_classes = (options[:class] || '').split(' ')
      option_classes << 'form-group'
      option_classes << 'required' if required_fields.include?(name)

      if options[:label].nil? || options[:label]
        label_options = options.delete(:label_options) || {}
        label_options[:for] = field_id
        caption = (options.delete(:label) || name.to_s.humanize.titleize)
        label = :label.wrap(label_options) { caption } if caption
      else
        options.delete(:label)
        label = ''
      end

      hint = options.delete(:hint)
      if hint
        hint_class = [
          'help-block',
          'text-muted',
          options.delete(:hint_class)
        ].compact.join(' ')
        hint = :small.wrap(class: hint_class) { hint }
      end

      error_message = if has_error
                        option_classes << 'has-error'
                        :div.wrap(class: 'help-block error invalid-feedback') { err.join(', ') }
                      else
                        ''
                      end

      field_input = input_html + error_message.to_s + hint.to_s

      options[:class] = option_classes.join(' ')

      :div.wrap(options) { label.to_s + field_input }
    end

    #  ====================================
    #  = Option tags nested within Select =
    #  ====================================

    def options_for_select(model, opts = {})
      opts[:value_field] ||= 'id'
      opts[:text_field] ||= 'name'
      begin
        model.order(opts[:text_field].to_sym)
             .select_hash(opts[:value_field].to_sym, opts[:text_field].to_sym)
      rescue
        []
      end
    end

    def make_name(object, name, _options = {})
      if @dn_current_field_name.present?
        "#{object.class_name.underscore}[#{@dn_current_field_name}][#{name}]"
      else
        "#{object.class_name.underscore}[#{name}]"
      end
    end

    def dn_form_helper_value(object, name)
      if @dn_current_field_name.present?
        return unless object.send(@dn_current_field_name).is_a?(Hash)
        object.send(@dn_current_field_name)[name]
      else
        object.send(name)
      end
    end

    class FormModel
      def initialize(context, model_obj)
        @context = context
        @model   = model_obj
      end

      def fields_for(field_name, namespace = nil)
        @context.instance_variable_set('@dn_current_field_name', field_name)
        @context.instance_variable_set('@dn_current_namespace', namespace)
        yield self
        @context.instance_variable_set('@dn_current_field_name', nil)
        @context.instance_variable_set('@dn_current_namespace', nil)
      end

      def method_missing(meth, *args)
        @context.send(meth, @model, *args)
      end
    end

    # ==========================
    # = helpers for helpers :) =
    # ==========================
  end
end

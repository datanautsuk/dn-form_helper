# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'Datanauts::FormHelper#checkbox' do
  let(:user) do
    User.new(first_name: 'Jo',
             last_name: 'Blogs',
             preferences: %w[foo bar],
             admin: true,
             super: false)
  end
  let(:form) { Datanauts::FormHelper::FormModel.new(self, user) }
  let(:prefs) do
    { foo: 'Some Foo', bar: 'Some Bar', baz: 'Some Baz', fiz: 'Some Fizz' }
  end

  context 'checkbox' do
    it 'renders a checkbox with a true value' do
      f = form.checkbox(:admin)

      expect(f.no_white_space).to eql <<-INPUT.no_white_space.strip
        <div class="form-check">
          <input type="hidden" name="user[admin]" id="user_admin_false" value="0" />
          <input type="checkbox" name="user[admin]" id="user_admin_true" value="1" checked="checked" class="form-check-input" />
          <label for="user_admin_true" class="form-check-label">Admin</label>
        </div>
      INPUT
    end

    it 'renders a checkbox with a false value' do
      f = form.checkbox(:super, label: 'Super User?')
      expect(f.no_white_space).to eql <<-INPUT.no_white_space.strip
        <div class="form-check">
          <input type="hidden" name="user[super]" id="user_super_false" value="0" />
          <input type="checkbox" name="user[super]" id="user_super_true" value="1" class="form-check-input" />
          <label for="user_super_true" class="form-check-label">Super User?</label>
        </div>
      INPUT
    end

    it 'renders a group of checkboxes with some options checked' do
      f = form.checkbox_group(:preferences, options: prefs, include_blank: true)

      expect(f.no_white_space).to eql <<-INPUT.no_white_space.strip
        <div class="form-group"><label class="d-block mb-2" for="user_preferences">Preferences</label>
          <input type="hidden" name="user[preferences][]" id="user_preferences_empty" />
          <div class="form-check"><input class="form-check-input" id="user_preferences_foo" name="user[preferences][]" type="checkbox" value="foo" /><label class="form-check-label" for="user_preferences_foo">Some Foo</label></div>
          <div class="form-check"><input class="form-check-input" id="user_preferences_bar" name="user[preferences][]" type="checkbox" value="bar" /><label class="form-check-label" for="user_preferences_bar">Some Bar</label></div>
          <div class="form-check"><input class="form-check-input" id="user_preferences_baz" name="user[preferences][]" type="checkbox" value="baz" /><label class="form-check-label" for="user_preferences_baz">Some Baz</label></div>
          <div class="form-check"><input class="form-check-input" id="user_preferences_fiz" name="user[preferences][]" type="checkbox" value="fiz" /><label class="form-check-label" for="user_preferences_fiz">Some Fizz</label></div>
        </div>
      INPUT
    end
  end
end
# rubocop:enable Metrics/BlockLength

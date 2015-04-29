require 'spec_helper'

describe 'Datanauts::FormHelper#checkbox' do
  before do
    @user = User.new(:first_name => 'Jo', :last_name => 'Blogs', :preferences => ['foo', 'bar'], :admin => true, :super => false)
  end
  
  context 'checkbox' do
    it 'renders a checkbox with a true value' do
      f = checkbox(@user, :admin)
      expect(f.no_white_space).to eql '<div class="checkbox form-group">
        <input type="hidden" name="user[admin]" id="user_admin_false" value="0" />
        <label>
        <input type="checkbox" name="user[admin]" id="user_admin_true" value="1" checked="checked" />
        Admin
        </label>
        </div>'.no_white_space
    end
    
    it 'renders a checkbox with a false value' do
      f = checkbox(@user, :super, :label => 'Super User?')
      expect(f.no_white_space).to eql '<div class="checkbox form-group">
        <input type="hidden" name="user[super]" id="user_super_false" value="0" />
        <label>
        <input type="checkbox" name="user[super]" id="user_super_true" value="1" />
        Super User?
        </label>
        </div>'.no_white_space
      expect(f).to be_html_safe
    end

    it 'renders a group of checkboxes with some options checked' do
      prefs = { foo: 'Some Foo', bar: 'Some Bar', baz: 'Some Baz', fiz: 'Some Fizz'}
      f = checkbox_group(@user, :preferences, :options => prefs)
      # puts f
      expect(f.no_white_space).to eql '<div class="form-group"><label class="control-label" for="user_preferences">Preferences</label>
          <input type="hidden" name="user[preferences][]" id="user_preferences_empty" />
          <div class="checkbox"><label><input type="checkbox" name="user[preferences][]" id="user_preferences_foo" value="foo" />Some Foo</label></div>
          <div class="checkbox"><label><input type="checkbox" name="user[preferences][]" id="user_preferences_bar" value="bar" />Some Bar</label></div>
          <div class="checkbox"><label><input type="checkbox" name="user[preferences][]" id="user_preferences_baz" value="baz" />Some Baz</label></div>
          <div class="checkbox"><label><input type="checkbox" name="user[preferences][]" id="user_preferences_fiz" value="fiz" />Some Fizz</label></div>
          </div>'.no_white_space
    end
    
  end
  

end
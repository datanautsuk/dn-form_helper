require 'spec_helper'

describe 'Datanauts::FormHelper#input' do
  before do
    @user = User.new(:first_name => 'Jo', :last_name => 'Blogs')
    # allow(@user).to receive(:first_name) {"the first_name"}
  end
  
  include Datanauts::FormHelper
  
  context 'with no arguments' do
    it 'returns the right thing' do
      
      f = form_for(@user) do |ff|
        ff.input(:first_name, :hint => 'foo') + ff.input(:last_name) + ff.input(:email, :hint => 'bar')
      end
      # binding.pry; 
      
      expect(f.chomp).to match '<form method="post"><div class="form-group required"><label class="control-label" for="user_first_name">First Name</label>
<input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" /><div class="help-block">foo</div>
</div>
<div class="form-group required"><label class="control-label" for="user_last_name">Last Name</label>
<input id="user_last_name" class="form-control" type="text" name="user[last_name]" value="Blogs" /></div>
<div title="is missing" class="form-group required has-error"><label class="control-label" for="user_email">Email</label>
<input id="user_email" class="form-control" type="text" name="user[email]" /><div class="help-block">bar</div>
<div class="help-block error">is missing</div>
</div>
</form>'

    end
  end
end
require 'spec_helper'

describe 'Datanauts::FormHelper#input' do
  before do
    @user = User.new(:first_name => 'Jo', :last_name => 'Blogs')
    # allow(@user).to receive(:first_name) {"the first_name"}
  end
  
  include Datanauts::FormHelper
  
  context 'single field' do
    it 'returns the right thing' do
      
      f = form_for(@user) do |ff|
        ff.input(:first_name)
      end
      
      expect(f.chomp).to match '<form method="post"><div class="form-group"><label class="control-label" for="user_first_name">First Name</label>
<input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" /></div>
</form>'
    end
    
    context 'with required field' do
      context 'with the require field missing' do
        
        it 'adds the required class to the wrapper div' do
          allow(@user).to receive(:email) {nil}
          
          f = form_for(@user) do |ff|
            ff.input(:email)
          end
          
          expect(f.chomp).to match '<form method="post"><div class="form-group required has-error"><label class="control-label" for="user_email">Email</label>
<input id="user_email" class="form-control" type="text" name="user[email]" /><div class="help-block error">is missing</div>
</div>
</form>'
    
        end
      end
    end
    
  end
    
    
end
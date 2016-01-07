require 'spec_helper'

describe 'Datanauts::FormHelper#input' do
  before do
    @user = User.new(:first_name => 'Jo', :last_name => 'Blogs')
  end

  context 'single field' do
    it 'returns the right thing' do

      f = input(@user, :first_name)

      expect(f.chomp).to eql '<div class="form-group"><label for="user_first_name">First Name</label>
<input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" /></div>'.no_white_space
    end

    context 'with required field' do
      context 'missing' do

        it 'adds the error class to the wrapper div and the message block' do

          f = input(@user, :email)

          expect(f.chomp).to eql '<div class="form-group required has-error"><label for="user_email">Email</label>
<input id="user_email" class="form-control" type="text" name="user[email]" /><div class="help-block error">is missing</div>
</div>'.no_white_space

        end
      end

      context 'present' do
        it 'doesnt add the error class to the wrapper div' do
          allow(@user).to receive(:email) {'blah@foo.com'}

          f = input(@user, :email)

          expect(f.chomp).to eql '<div class="form-group required"><label for="user_email">Email</label>
<input id="user_email" class="form-control" type="text" name="user[email]" value="blah@foo.com" /></div>'.no_white_space

        end
      end

    end

    context 'with hint' do
      it 'adds the hint' do

        f = input(@user, :first_name, :hint => 'foo')

        expect(f.chomp).to eql '<div class="form-group"><label for="user_first_name">First Name</label>
<input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" /><div class="help-block">foo</div>
</div>'.no_white_space

      end
    end

    context 'with user defined class' do
      context 'on wrapper div' do
        it 'adds a class to form-group' do

          f = input(@user, :first_name, :hint => 'foo', :class => 'boo')

          expect(f.chomp).to eql '<div class="boo form-group"><label for="user_first_name">First Name</label>
<input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" /><div class="help-block">foo</div>
</div>'.no_white_space

        end
      end

      context 'on input tag' do
        it 'adds a class to input' do

          f = input(@user, :first_name, :hint => 'foo', :input_options => {:class => 'boo'})

          expect(f.chomp).to eql '<div class="form-group"><label for="user_first_name">First Name</label>
<input id="user_first_name" class="form-control boo" type="text" name="user[first_name]" value="Jo" /><div class="help-block">foo</div>
</div>'.no_white_space

        end
      end

      context 'with addons' do

        it 'adds addon to the beginning of the input' do

         f = input(@user, :first_name, :prepend => '£')

      expect(f.chomp).to eql '<div class="form-group"><label for="user_first_name">First Name</label>
<div class="input-group"><div class="input-group-addon">£</div><input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" /></div></div>'.no_white_space

        end

        it 'adds addon to the end of the input' do

         f = input(@user, :first_name, :append => '.00')

      expect(f.chomp).to eql '<div class="form-group"><label for="user_first_name">First Name</label>
<div class="input-group"><input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" />
<div class="input-group-addon">.00</div>
</div>
</div>'.no_white_space

        end


      end
    end

    it 'is a hidden input' do
      f = hidden(@user, :hidden_thing)
      expect(f.chomp).to eql '<input id="user_hidden_thing" class="form-control" type="hidden" name="user[hidden_thing]" />'.no_white_space
    end
  end
end
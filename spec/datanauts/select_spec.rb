require 'spec_helper'

describe 'Datanauts::FormHelper#select' do
  before do
    @user = User.new(:first_name => 'Jo', :last_name => 'Blogs', :select_thing => nil)
  end
  
  context 'with no options' do
    it 'returns a select tag with a default prompt' do
      f = select(@user, :select_thing)
      expect(f.chomp).to eql '<div class="form-group"><label class="control-label" for="user_select_thing">Select Thing</label>
<select id="user_select_thing" class="form-control" name="user[select_thing]"><option value="">Choose</option>
</select>
</div>'
    end
    
    it 'returns a select without an option' do
      f = select(@user, :select_thing, :prompt => false)
      expect(f.chomp).to eql '<div class="form-group"><label class="control-label" for="user_select_thing">Select Thing</label>
<select id="user_select_thing" class="form-control" name="user[select_thing]"></select>
</div>'
    end
    
    it 'returns a select tag with a user defined prompt' do
      f = select(@user, :select_thing, :prompt => "Hello!")
      expect(f.chomp).to eql '<div class="form-group"><label class="control-label" for="user_select_thing">Select Thing</label>
<select id="user_select_thing" class="form-control" name="user[select_thing]"><option value="">Hello!</option>
</select>
</div>'
    end
    
  end
  
  context 'with some options' do
    it 'has some options' do
      f = select(@user, :select_thing, :options => %w(foo bar baz))
      expect(f.chomp).to eql '<div class="form-group"><label class="control-label" for="user_select_thing">Select Thing</label>
<select id="user_select_thing" class="form-control" name="user[select_thing]"><option value="">Choose</option>
<option value="foo">Foo</option>
<option value="bar">Bar</option>
<option value="baz">Baz</option>
</select>
</div>'
    end
    
    it 'has some options with values' do
      f = select(@user, :select_thing, :options => {:foo => "one", :bar => "two", :baz => "three"})
      expect(f.chomp).to eql '<div class="form-group"><label class="control-label" for="user_select_thing">Select Thing</label>
<select id="user_select_thing" class="form-control" name="user[select_thing]"><option value="">Choose</option>
<option value="foo">one</option>
<option value="bar">two</option>
<option value="baz">three</option>
</select>
</div>'
    end
    
    it 'adds the selected attribute to the correct option tag' do
      allow(@user).to receive(:select_thing) { 'bar' }
      f = select(@user, :select_thing, :options => {:foo => "one", :bar => "two", :baz => "three"})
      expect(f.chomp).to eql '<div class="form-group"><label class="control-label" for="user_select_thing">Select Thing</label>
<select id="user_select_thing" class="form-control" name="user[select_thing]"><option value="">Choose</option>
<option value="foo">one</option>
<option value="bar" selected="selected">two</option>
<option value="baz">three</option>
</select>
</div>'
    end
  end
  
end
require 'spec_helper'

describe 'XSS protection' do
  before do
    @user = User.new(:first_name => '"><script>alert("xss")</script>', :last_name => 'Blogs')
  end
  
  describe '#input' do
    it 'escapes html tags in values' do
      f = input(@user, :first_name)
      
      expect(f).to_not include "<script>"
      expect(f).to include '&lt;script&gt;'
    end
    
    it 'returns html_safe strings' do
      f = input(@user, :first_name, :hint => 'this is a hint')
      expect(f + "not safe!").to be_html_safe
    end
    
  end
  
  describe '#textarea' do
    it 'escapes html tags in values' do
      f = textarea(@user, :first_name)
      
      expect(f).to_not include "<script>"
      expect(f).to include '&lt;script&gt;'
    end
    
  end
  
  describe 'form_for' do
    it 'should be html safe' do
      f = form_for(@user) {"<p>abc def</p>"}
      expect(f).to be_html_safe
    end    
  end
  
end
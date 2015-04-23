require 'spec_helper'
require 'active_support/core_ext/string/output_safety'

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
      f = input(@user, :first_name)
      expect(f).to be_html_safe
    end
    
  end
  
  describe '#textarea' do
    it 'escapes html tags in values' do
      f = textarea(@user, :first_name)
      
      expect(f).to_not include "<script>"
      expect(f).to include '&lt;script&gt;'
    end
    
  end
  
end
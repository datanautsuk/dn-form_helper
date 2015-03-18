require 'spec_helper'

describe 'Datanauts::FormHelper#form_for' do
  before do
    @obj = double('object')
    allow(@obj).to receive(:new?) {false}
  end
  
  include Datanauts::FormHelper
  
  it 'has a version number' do
    expect(Datanauts::FormHelper::VERSION).not_to be nil
  end

  it 'doesnt raise an error' do
    expect { form_for(@obj) {"<p>abc def</p>"} }.not_to raise_error
  end
  
  context 'with no arguments' do
    it 'returns the right thing' do
      f = form_for(@obj) {"<p>abc def</p>"}
      expect(f.chomp).to match '<form method="post"><p>abc def</p></form>'
    end
  end
  
  context 'with action' do
    it 'returns the right thing' do
      f = form_for(@obj, :action => '/foo') {"<p>abc def</p>"}
      expect(f.chomp).to match '<form method="post" action="/foo"><p>abc def</p></form>'
    end
  end
end
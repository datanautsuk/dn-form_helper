require 'spec_helper'

describe 'Datanauts::FormHelper#form_for' do
  before do
    @user = User.new(:first_name => 'Jo', :last_name => 'Blogs')
  end

  include Datanauts::FormHelper
  def request
    r = double('request')
    allow(r).to receive(:script_name) { "/admin" }
    r
  end

  it 'has a version number' do
    expect(Datanauts::FormHelper::VERSION).not_to be nil
  end

  it 'doesnt raise an error' do
    expect { form_for(@user) {"<p>abc def</p>"} }.not_to raise_error
  end

  context 'with no arguments' do
    it 'returns the right thing' do
      f = form_for(@user) {"<p>abc def</p>"}
      expect(f.no_white_space).to match '<form method="post" action="/admin/users/1">
        <input type="hidden" name="_method" value="put" />
        <p>abc def</p>
      </form>'.no_white_space
    end
  end

  context 'with action' do
    it 'returns the right thing' do
      f = form_for(@user, :action => '/foo') {"<p>abc def</p>"}
      expect(f.no_white_space).to match '<form method="post" action="/foo">
      <input type="hidden" name="_method" value="put" />
      <p>abc def</p></form>'.no_white_space
    end
  end


end
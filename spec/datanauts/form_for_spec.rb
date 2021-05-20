# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'Datanauts::FormHelper#form_for' do
  before do
    @user = User.new(first_name: 'Jo', last_name: 'Blogs')
  end

  include Datanauts::FormHelper
  def request
    r = double('request')
    allow(r).to receive(:script_name) { '/admin' }
    r
  end

  it 'has a version number' do
    expect(Datanauts::FormHelper::VERSION).not_to be nil
  end

  it 'doesnt raise an error' do
    expect { form_for(@user) { '<p>abc def</p>' } }.not_to raise_error
  end

  context 'with no arguments' do
    it 'returns the right thing' do
      f = form_for(@user) { '<p>abc def</p>' }

      expect(f.no_white_space).to match <<-FORM.no_white_space.strip
        <form method="post" action="/admin/users/1" class="form was-validated">
          <input type="hidden" name="_method" value="put" />
          <p>abc def</p>
        </form>
      FORM
    end
  end

  context 'with action' do
    it 'returns the right thing' do
      f = form_for(@user, action: '/foo') { '<p>abc def</p>' }
      expect(f.no_white_space).to match <<-FORM.no_white_space.strip
        <form method="post" action="/foo" class="form was-validated">
          <input type="hidden" name="_method" value="put" />
          <p>abc def</p>
        </form>
      FORM
    end
  end

  context 'with method override' do
    it 'returns the right thing' do
      f = form_for(@user, method: 'POST') { '<p>abc def</p>' }

      expect(f.no_white_space).to match <<-FORM.no_white_space.strip
        <form method="POST" action="/admin/users/1" class="form was-validated">
          <p>abc def</p>
        </form>
      FORM
    end
  end
end
# rubocop:enable Metrics/BlockLength

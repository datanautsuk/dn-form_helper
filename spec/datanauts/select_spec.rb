# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'Datanauts::FormHelper#select' do
  let(:user) do
    User.new(first_name: 'Jo', last_name: 'Blogs', select_thing: nil)
  end

  let(:form) { Datanauts::FormHelper::FormModel.new(self, user) }

  context 'with no options' do
    it 'returns a select tag with a default prompt' do
      f = form.select(:select_thing)

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control">
            <option value="">choose...</option>
          </select>
        </div>
      INPUT
    end

    it 'returns a select without an option' do
      f = form.select(:select_thing, prompt: false)
      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control"></select>
        </div>
      INPUT
    end

    it 'returns a select tag with a user defined prompt' do
      f = form.select(:select_thing, prompt: 'Hello!')
      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control">
            <option value="">Hello!</option>
          </select>
        </div>
      INPUT
    end
  end

  context 'with some options' do
    it 'has some options' do
      f = form.select(:select_thing, options: %w[foo bar baz])

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control">
            <option value="">choose...</option>
            <option value="foo">Foo</option>
            <option value="bar">Bar</option>
            <option value="baz">Baz</option>
          </select>
        </div>
      INPUT
    end

    it 'has some options with values' do
      f = form.select(:select_thing,
                      options: { foo: 'one', bar: 'two', baz: 'three' })

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control">
            <option value="">choose...</option>
            <option value="foo">one</option>
            <option value="bar">two</option>
            <option value="baz">three</option>
          </select>
        </div>
      INPUT
    end

    it 'adds the selected attribute to the correct option tag' do
      allow(user).to receive(:select_thing) { 'bar' }
      f = form.select(:select_thing, options: { foo: 'one', bar: 'two', baz: 'three' })

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control">
            <option value="">choose...</option>
            <option value="foo">one</option>
            <option value="bar" selected>two</option>
            <option value="baz">three</option>
          </select>
        </div>
      INPUT
    end
  end

  context 'with addons' do
    it 'adds addon to the beginning of the input' do
      f = form.select(:select_thing,
                      prepend: '£',
                      options: { foo: 'one', bar: 'two', baz: 'three' })

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <div class="input-group">
            <div class="input-group-prepend">
              <div class="input-group-text">£</div>
            </div>
            <select name="user[select_thing]" id="user_select_thing" class="form-control">
              <option value="">choose...</option>
              <option value="foo">one</option>
              <option value="bar">two</option>
              <option value="baz">three</option>
            </select>
          </div>
        </div>
      INPUT
    end

    it 'adds addon to the end of the input' do
      f = form.select(:select_thing,
                      append: '.00',
                      options: { foo: 'one', bar: 'two', baz: 'three' })

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <div class="input-group">
            <select name="user[select_thing]" id="user_select_thing" class="form-control">
              <option value="">choose...</option>
              <option value="foo">one</option>
              <option value="bar">two</option>
              <option value="baz">three</option>
            </select>
            <div class="input-group-append">
              <div class="input-group-text">.00</div>
            </div>
          </div>
        </div>
      INPUT
    end
  end

  context 'by group' do
    let(:grouped_options) do
      [
        { id: 1, name: 'foo', group: 'one' },
        { id: 2, name: 'bar', group: 'one' },
        { id: 3, name: 'baz', group: 'two' }
      ].map { |h| OpenStruct.new(h) }
    end

    it 'has some options with values' do
      f = form.select(:select_thing, options: grouped_options, group: :group)

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_select_thing">Select Thing</label>
          <select name="user[select_thing]" id="user_select_thing" class="form-control">
            <option value="">choose...</option>
            <optgroup label="one">
              <option value="1">foo</option>
              <option value="2">bar</option>
            </optgroup>
            <optgroup label="two">
              <option value="3">baz</option>
            </optgroup>
          </select>
        </div>
      INPUT
    end
  end
end
# rubocop:enable Metrics/BlockLength

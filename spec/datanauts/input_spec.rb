# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'Datanauts::FormHelper#input' do
  let(:user) { User.new(first_name: 'Jo', last_name: 'Blogs') }
  let(:form) { Datanauts::FormHelper::FormModel.new(self, user) }

  context 'single field' do
    it 'returns the right thing' do
      f = form.input(:first_name)

      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <div class="form-group">
          <label for="user_first_name">First Name</label>
          <input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" />
        </div>
      INPUT
    end

    context 'with required field' do
      context 'missing' do
        it 'adds the error class to the wrapper div and the message block' do
          f = form.input(:email)
          expect(f.chomp).to eql <<-INPUT.no_white_space.strip
            <div class="form-group has-error required">
              <label for="user_email">Email</label>
              <input id="user_email" class="form-control is-invalid" type="text" name="user[email]" required />
              <div class="invalid-feedback">is missing</div>
            </div>
          INPUT
        end
      end

      context 'present' do
        it 'doesnt add the error class to the wrapper div' do
          allow(user).to receive(:email) { 'blah@foo.com' }

          f = form.input(:email)

          expect(f.chomp).to eql <<-INPUT.no_white_space.strip
            <div class="form-group required">
              <label for="user_email">Email</label>
              <input id="user_email" class="form-control" type="text" name="user[email]" value="blah@foo.com" required />
            </div>
          INPUT
        end
      end
    end

    context 'with hint' do
      it 'adds the hint' do
        f = form.input(:first_name, hint: 'foo')

        expect(f.chomp).to eql <<-INPUT.no_white_space.strip
          <div class="form-group">
            <label for="user_first_name">First Name</label>
            <input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" />
            <small class="help-block text-muted">foo</small>
          </div>
        INPUT
      end
    end

    context 'with user defined class' do
      context 'on wrapper div' do
        it 'adds a class to form-group' do
          f = form.input(:first_name, hint: 'foo', class: 'boo')

          expect(f.chomp).to eql <<-INPUT.no_white_space.strip
            <div class="boo form-group">
              <label for="user_first_name">First Name</label>
              <input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" />
              <small class="help-block text-muted">foo</small>
            </div>
          INPUT
        end
      end

      context 'on input tag' do
        it 'adds a class to input' do
          f = form.input(:first_name,
                         hint: 'foo', input_options: { class: 'boo' })

          expect(f.chomp).to eql <<-INPUT.no_white_space.strip
            <div class="form-group">
              <label for="user_first_name">First Name</label>
              <input id="user_first_name" class="form-control boo" type="text" name="user[first_name]" value="Jo" />
              <small class="help-block text-muted">foo</small>
            </div>
          INPUT
        end
      end

      context 'with addons' do
        it 'adds addon to the beginning of the input' do
          f = form.input(:first_name, prepend: '£')

          expect(f.chomp).to eql <<-INPUT.no_white_space.strip
            <div class="form-group">
              <label for="user_first_name">First Name</label>
              <div class="input-group">
                <div class="input-group-prepend">
                  <div class="input-group-text">£</div>
                </div>
                <input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" />
              </div>
            </div>
          INPUT
        end

        it 'adds addon to the end of the input' do
          f = form.input(:first_name, append: '.00')

          expect(f.chomp).to eql <<-INPUT.no_white_space.strip
            <div class="form-group">
              <label for="user_first_name">First Name</label>
              <div class="input-group">
                <input id="user_first_name" class="form-control" type="text" name="user[first_name]" value="Jo" />
                <div class="input-group-append">
                  <div class="input-group-text">.00</div>
                </div>
              </div>
            </div>
          INPUT
        end
      end
    end

    it 'is a hidden input' do
      f = form.hidden(:hidden_thing)
      expect(f.chomp).to eql <<-INPUT.no_white_space.strip
        <input id="user_hidden_thing" class="form-control" type="hidden" name="user[hidden_thing]" />
      INPUT
    end
  end
end
# rubocop:enable Metrics/BlockLength

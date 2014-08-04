require 'spec_helper'

describe ResponseToggler do
  before do
    ResponseToggler.connection.flushdb
  end

  describe '.disable' do
    it 'marks a given namespace as disabled' do
      ResponseToggler.disable('capture')
      expect(ResponseToggler.connection.get('fake-braspag.disabled_response.capture')).to be_truthy
    end
  end

  describe '.enable' do
    it 'marks a given namespace as enabled' do
      ResponseToggler.disable('capture')

      expect(ResponseToggler.connection.get('fake-braspag.disabled_response.capture')).to be_truthy

      ResponseToggler.enable('capture')

      expect(ResponseToggler.connection.get('fake-braspag.disabled_response.capture')).to be_nil
    end
  end

  describe '.enabled?' do
    it 'checks if the response is enabled' do
      ResponseToggler.disable('capture')

      expect(ResponseToggler.enabled?('capture')).to be_falsy

      ResponseToggler.enable('capture')

      expect(ResponseToggler.enabled?('capture')).to be_truthy
    end
  end
end

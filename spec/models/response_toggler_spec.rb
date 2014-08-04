require 'spec_helper'

describe ResponseToggler do
  before do
    ResponseToggler.connection.flushdb
  end

  describe '#disable' do
    it 'set the namespace key to true' do
      ResponseToggler.disable('capture')
      expect(ResponseToggler.connection.get('fake-braspag.disabled_response.capture')).to be_truthy
    end
  end

  describe '#enable' do
    it 'remove the namespace from the collection' do
      ResponseToggler.disable('capture')

      expect(ResponseToggler.connection.get('fake-braspag.disabled_response.capture')).to be_truthy

      ResponseToggler.enable('capture')

      expect(ResponseToggler.connection.get('fake-braspag.disabled_response.capture')).to be_nil
    end
  end
end

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
end

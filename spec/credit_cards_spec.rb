require 'spec_helper'
require 'active_support/core_ext/string/strip'

describe FakeBraspag::CreditCards do
  describe 'WSDL' do
    it 'displays the service WSDL with the appropriate endpoint URL' do
      described_class.set :wsdl_url, 'http://fa.ke/Service/wsdl.asmx'

      get '/FakeCreditCard/CartaoProtegido.asmx'

      expect(last_response).to be_ok
      expect(last_response.body).to match('location="http://fa.ke/Service/wsdl.asmx"')
    end
  end
end

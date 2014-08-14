require 'spec_helper'
require 'active_support/core_ext/string/strip'

describe FakeBraspag::CreditCards do
  describe 'WSDL' do
    it 'renders the service WSDL with the appropriate endpoint URL' do
      described_class.set :wsdl_url, 'http://fa.ke/Service/wsdl.asmx'

      get '/FakeCreditCard/CartaoProtegido.asmx'

      expect(last_response).to be_ok
      expect(last_response.body).to match('location="http://fa.ke/Service/wsdl.asmx"')
    end
  end

  describe 'SaveCreditCard' do
    it 'renders a successful response with a valid just click key and a correlation id' do
      request_id = 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
      just_click_key = '370a5342-c97a-4e55-8157-95c23fe18d03'

      allow(SecureRandom).to receive(:uuid).and_return(just_click_key)

      post 'FakeCreditCard/CartaoProtegido.asmx', <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://www.cartaoprotegido.com.br/WebService/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <tns:SaveCreditCard>
              <tns:saveCreditCardRequestWS>
                <tns:RequestId>{#{request_id.upcase}}</tns:RequestId>
                <tns:MerchantKey>{84BE7E7F-698A-6C74-F820-AE359C2A07C2}</tns:MerchantKey>
                <tns:CustomerName>John</tns:CustomerName>
                <tns:CardHolder>John Doe</tns:CardHolder>
                <tns:CardNumber>4111111111111111</tns:CardNumber>
                <tns:CardExpiration>05/2017</tns:CardExpiration>
              </tns:saveCreditCardRequestWS>
            </tns:SaveCreditCard>
          </env:Body>
        </env:Envelope>
      XML

      expect(last_response).to be_ok

      expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <soap:Body>
            <SaveCreditCardResponse xmlns="http://www.cartaoprotegido.com.br/WebService/">
              <SaveCreditCardResult>
                <JustClickKey>#{just_click_key}</JustClickKey>
                <CorrelationId>#{request_id}</CorrelationId>
                <Success>true</Success>
              </SaveCreditCardResult>
            </SaveCreditCardResponse>
          </soap:Body>
        </soap:Envelope>
      XML
    end

    it 'renders a failure response when no RequestId is provided' do
      post 'FakeCreditCard/CartaoProtegido.asmx', <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://www.cartaoprotegido.com.br/WebService/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <tns:SaveCreditCard>
              <tns:saveCreditCardRequestWS>
                <tns:RequestId></tns:RequestId>
                <tns:MerchantKey>{84BE7E7F-698A-6C74-F820-AE359C2A07C2}</tns:MerchantKey>
                <tns:CustomerName>John</tns:CustomerName>
                <tns:CardHolder>John Doe</tns:CardHolder>
                <tns:CardNumber>4111111111111111</tns:CardNumber>
                <tns:CardExpiration>05/2017</tns:CardExpiration>
              </tns:saveCreditCardRequestWS>
            </tns:SaveCreditCard>
          </env:Body>
        </env:Envelope>
      XML

      expect(last_response).to be_ok

      expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <soap:Body>
            <SaveCreditCardResponse xmlns="http://www.cartaoprotegido.com.br/WebService/">
              <SaveCreditCardResult>
                <Success>false</Success>
                <CorrelationId>00000000-0000-0000-0000-000000000000</CorrelationId>
                <ErrorReportCollection>
                  <ErrorReport>
                    <ErrorCode>732</ErrorCode>
                    <ErrorMessage>SaveCreditCardRequestId can not be null</ErrorMessage>
                  </ErrorReport>
                </ErrorReportCollection>
                <JustClickKey>00000000-0000-0000-0000-000000000000</JustClickKey>
              </SaveCreditCardResult>
            </SaveCreditCardResponse>
          </soap:Body>
        </soap:Envelope>
      XML
    end
  end

  describe 'JustClickShop' do
    it 'renders a successful response' do
      request_id = 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
      just_click_key = '370a5342-c97a-4e55-8157-95c23fe18d03'
      amount = 1234

      post 'FakeCreditCard/CartaoProtegido.asmx', <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://www.cartaoprotegido.com.br/WebService/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <tns:JustClickShop>
              <tns:justClickShopRequestWS>
                <tns:RequestId>{#{request_id.upcase}}</tns:RequestId>
                <tns:MerchantKey>{84BE7E7F-698A-6C74-F820-AE359C2A07C2}</tns:MerchantKey>
                <tns:CustomerName>John</tns:CustomerName>
                <tns:OrderId>123456</tns:OrderId>
                <tns:Amount>#{amount}</tns:Amount>
                <tns:PaymentMethod>997</tns:PaymentMethod>
                <tns:NumberInstallments>1</tns:NumberInstallments>
                <tns:PaymentType>0</tns:PaymentType>
                <tns:JustClickKey>{#{just_click_key.upcase}}</tns:JustClickKey>
                <tns:SecurityCode>123</tns:SecurityCode>
              </tns:justClickShopRequestWS>
            </tns:JustClickShop>
          </env:Body>
        </env:Envelope>
      XML

      expect(last_response).to be_ok

      expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <soap:Body>
            <JustClickShopResponse xmlns="http://www.cartaoprotegido.com.br/WebService/">
              <JustClickShopResult>
                <Success>true</Success>
                <CorrelationId>#{request_id}</CorrelationId>
                <AquirerTransactionId>1234567890</AquirerTransactionId>
                <Amount>#{amount}</Amount>
                <AuthorizationCode>???</AuthorizationCode>
                <Status>???</Status>
                <ReturnCode>???</ReturnCode>
                <ReturnMessage>???</ReturnMessage>
              </JustClickShopResult>
            </JustClickShopResponse>
          </soap:Body>
        </soap:Envelope>
      XML
    end
  end
end

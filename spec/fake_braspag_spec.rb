require 'spec_helper'

describe FakeBraspag::Application do
  before do
    Order.connection.flushdb
  end

  let(:order_params) do
    {
      'merchantId' => '{E8D92C40-BDA5-C19F-5C4B-F3504A0CFE80}',
      'order' => '',
      'orderId' => '783842',
      'customerName' => 'Rafael França',
      'amount' => '18,36',
      'paymentMethod' => '997',
      'holder' => 'Rafael Franca',
      'cardNumber' => '4111111111111111',
      'expiration' => '05/17',
      'securityCode' => '123',
      'numberPayments' => '1',
      'typePayment' => '0'
    }
  end

  context 'authorization' do
    context 'with valid credit card' do
      it 'responds with a success response' do
        post '/webservices/pagador/Pagador.asmx/Authorize', order_params

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>18.36</amount>
  <authorisationNumber>505369</authorisationNumber>
  <message>Operation Successful</message>
  <returnCode>4</returnCode>
  <status>1</status>
  <transactionId>0728043853882</transactionId>
</PagadorReturn>
        XML
      end

      it 'persists the order data' do
        post '/webservices/pagador/Pagador.asmx/Authorize', order_params

        expect(last_response).to be_ok

        order = Order.find('783842')
        expect(order.amount).to eq '18.36'
      end
    end

    context 'with invalid credit card' do
      it 'responds with a error response' do
        post '/webservices/pagador/Pagador.asmx/Authorize', order_params.merge('cardNumber' => '4242424242424242')

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>18.36</amount>
  <message>Not Authorized</message>
  <returnCode>2</returnCode>
  <status>2</status>
  <transactionId>0728043853882</transactionId>
</PagadorReturn>
        XML
      end

      it 'does not persist the order data' do
        post '/webservices/pagador/Pagador.asmx/Authorize', order_params.merge('cardNumber' => '4242424242424242')

        expect(last_response).to be_ok
        expect(Order.count).to eq 0
      end
    end
  end

  context 'capture' do
    it 'responds with a success response' do
      order = Order.create(order_params)

      post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                          'orderId' => order_params['orderId'] }



      expect(last_response).to be_ok
      expect(last_response.body).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>#{order.amount}</amount>
  <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:257575054    VALOR:        #{order.amount}@ESTAB:040187624 DINDA COM BR          @24.07.14-16:27:33 TERM:RO128278/528374@AUTORIZACAO EMISSOR: 642980           @CODIGO PRE-AUTORIZACAO: 52978         @CARTAO: ************1111              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
  <returnCode>0</returnCode>
  <transactionId>257575054</transactionId>
</PagadorReturn>
      XML
    end

    it 'marks the order as captured when the success happen' do
      order = Order.create(order_params)

      post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                          'orderId' => order_params['orderId'] }

      expect(last_response).to be_ok

      order = Order.find('783842')
      expect(order).to be_captured
    end

    it 'returns a order not found error when the order does not exist' do
      post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                          'orderId' => order_params['orderId'] }

      expect(last_response).to be_ok
      expect(last_response.body).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount xsi:nil="true"/>
  <message>Transaction not available for capture. Please check the status of this transaction.</message>
  <returnCode>1111</returnCode>
  <status xsi:nil="true"/>
</PagadorReturn>
      XML
    end
  end
end

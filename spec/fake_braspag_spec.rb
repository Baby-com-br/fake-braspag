require 'spec_helper'
require 'active_support/core_ext/string/strip'

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

  describe 'authorization' do
    context 'with valid credit card' do
      it 'responds with a successful response' do
        post '/webservices/pagador/Pagador.asmx/Authorize', order_params

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
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
        expect(last_response.body).to eq <<-XML.strip_heredoc
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

  describe 'capture' do
    context 'when the response is enabled' do
      before do
        ResponseToggler.enable('capture')
      end

      it 'renders a successful response with the order amount, return code and transaction id' do
        order = Order.create(order_params)

        post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                            'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>#{order.amount}</amount>
          <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:257575054    VALOR:        #{order.amount}@ESTAB:040187624 DINDA COM BR          @24.07.14-16:27:33 TERM:RO128278/528374@AUTORIZACAO EMISSOR: 642980           @CODIGO PRE-AUTORIZACAO: 52978         @CARTAO: xxxxxxxxxxxx1111              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
          <returnCode>0</returnCode>
          <transactionId>257575054</transactionId>
        </PagadorReturn>
        XML
      end

      it 'marks the order as captured when successful' do
        order = Order.create(order_params)

        post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                            'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok

        order = Order.find('783842')
        expect(order).to be_captured
      end

      it 'returns an order not found error when the order does not exist' do
        post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                            'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
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

    context 'when the response is enabled' do
      before do
        ResponseToggler.disable('capture')
      end

      it 'renders a failure response with the order amount, return code and transaction id' do
        order = Order.create(order_params)

        post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                            'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>#{order.amount}</amount>
          <message>Capture denied</message>
          <returnCode>2</returnCode>
          <transactionId>257575054</transactionId>
        </PagadorReturn>
        XML
      end

      it 'does not mark the order as captured when successful' do
        order = Order.create(order_params)

        post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                            'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok

        order = Order.find('783842')
        expect(order).not_to be_captured
      end

      it 'returns an order not found error when the order does not exist' do
        post '/webservices/pagador/Pagador.asmx/Capture', { 'merchantId' => order_params['merchantId'],
                                                            'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
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

  describe 'partial capture' do
    it 'renders a successful response with the captured amount and the transaction status' do
      order = Order.create(order_params)
      amount = '12,34'

      post '/webservices/pagador/Pagador.asmx/CapturePartial', { 'merchantId' => order_params['merchantId'],
                                                                 'orderId' => order_params['orderId'],
                                                                 'captureAmount' => amount }

      expect(last_response).to be_ok
      expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>12.34</amount>
          <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:247524362    VALOR:       12,34@                NUM. PARCELA:      01@ESTAB:040187624 DINDA COM BR          @24.07.14-16:38:47 TERM:RO128278/531425@AUTORIZACAO EMISSOR: 214111           @CODIGO PRE-AUTORIZACAO: 14111         @CARTAO: xxxxxxxxxxxx1111              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
          <returnCode>0</returnCode>
          <status>0</status>
        </PagadorReturn>
      XML
    end

    it 'returns a transaction not found error when the order does not exist' do
      amount = '12,34'

      post '/webservices/pagador/Pagador.asmx/CapturePartial', { 'merchantId' => order_params['merchantId'],
                                                                 'orderId' => order_params['orderId'],
                                                                 'captureAmount' => amount }

      expect(last_response).to be_ok
      expect(last_response.body).to eq <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount xsi:nil="true"/>
          <message>Transaction specified was not found in the database</message>
          <returnCode>1003</returnCode>
          <status xsi:nil="true"/>
        </PagadorReturn>
      XML
    end
  end

  describe 'disable capture' do
    it 'disables the capture response' do
      ResponseToggler.enable('capture')

      get '/capture/disable'

      expect(last_response).to be_ok

      expect(ResponseToggler.enabled?('capture')).to be_falsy
    end

    it 'returns not modified if the capture is already disabled' do
      ResponseToggler.disable('capture')

      get '/capture/disable'

      expect(last_response.status).to eq 304
    end
  end

  describe 'enable capture' do
    it 'enables the capture response' do
      ResponseToggler.disable('capture')

      get '/capture/enable'

      expect(last_response).to be_ok

      expect(ResponseToggler.enabled?('capture')).to be_truthy
    end

    it 'returns not modified if the capture is already enabled' do
      ResponseToggler.enable('capture')

      get '/capture/enable'

      expect(last_response.status).to eq 304
    end
  end
end

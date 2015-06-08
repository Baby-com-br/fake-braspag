# encoding: utf-8

require 'spec_helper'
require 'active_support/core_ext/string/strip'

describe FakeBraspag::Orders do
  before do
    Order.connection.flushdb
  end

  let(:order_params) do
    {
      'merchantId' => '{E8D92C40-BDA5-C19F-5C4B-F3504A0CFE80}',
      'order' => '',
      'orderId' => '994567',
      'customerName' => 'Antonio Carlos',
      'amount' => '18,36',
      'paymentMethod' => '42',
      'holder' => 'Antonio Carlos',
      'cardNumber' => '5555555555554444',
      'expiration' => '02/23',
      'securityCode' => '123',
      'numberPayments' => '1',
      'typePayment' => '0'
    }
  end

  describe 'get status order' do
    context 'when the response is enabled' do
      before do
        ResponseToggler.enable('get_status_order')
      end

      it 'renders a successful response with the order amount and the transaction status' do
        order = Order.create(order_params)

        post '/webservices/pagador/pedido.asmx/GetDadosPedido', { 'merchantId' => order_params['merchantId'],
                                                                   'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.pagador.com.br/">
            <CodigoAutorizacao>123456</CodigoAutorizacao>
            <CodigoPagamento>42</CodigoPagamento>
            <FormaPagamento>Redecard Webservice</FormaPagamento>
            <NumeroParcelas>1</NumeroParcelas>
            <Status>3</Status>
            <Valor>#{order.amount}</Valor>
            <DataPagamento>6/8/2015 10:09:57 AM</DataPagamento>
            <DataPedido>6/8/2015 10:09:45 AM</DataPedido>
            <TransId>654321</TransId>
            <BraspagTid>3144c006-2e50-4e79-bd15-215ac073f87c</BraspagTid>
          </DadosPedido>
        XML
      end

      it 'returns an empty xml when the order does not exist' do
        post '/webservices/pagador/pedido.asmx/GetDadosPedido', { 'merchantId' => order_params['merchantId'],
                                                                   'orderId' => '1234' }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xsi:nil="true" xmlns="http://www.pagador.com.br/"/>
        XML
      end
    end

    context 'when the response is disabled' do
      before do
        ResponseToggler.disable('get_status_order')
      end

      it 'renders a failure response with the order amount, return code and transaction id' do
        order = Order.create(order_params)

        post '/webservices/pagador/pedido.asmx/GetDadosPedido', { 'merchantId' => order_params['merchantId'],
                                                                   'orderId' => order_params['orderId'] }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.pagador.com.br/">
            <CodigoAutorizacao>123456</CodigoAutorizacao>
            <CodigoPagamento>42</CodigoPagamento>
            <FormaPagamento>Redecard Webservice</FormaPagamento>
            <NumeroParcelas>1</NumeroParcelas>
            <Status>4</Status>
            <Valor>#{order.amount}</Valor>
            <DataPagamento>6/8/2015 10:09:57 AM</DataPagamento>
            <DataPedido>6/8/2015 10:09:45 AM</DataPedido>
            <TransId>654321</TransId>
            <BraspagTid>3144c006-2e50-4e79-bd15-215ac073f87c</BraspagTid>
          </DadosPedido>
        XML
      end

      it 'returns an empty xml when the order does not exist' do
        post '/webservices/pagador/pedido.asmx/GetDadosPedido', { 'merchantId' => order_params['merchantId'],
                                                                   'orderId' => '1234' }

        expect(last_response).to be_ok
        expect(last_response.body).to eq <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xsi:nil="true" xmlns="http://www.pagador.com.br/"/>
        XML
      end
    end
  end

  describe 'disable get status order' do
    it 'disables the get status response' do
      ResponseToggler.enable('get_status_order')

      get '/get_status_order/disable'

      expect(last_response).to be_ok

      expect(ResponseToggler.enabled?('get_status_order')).to be_falsy
    end

    it 'returns not modified if the get status order is already disabled' do
      ResponseToggler.disable('get_status_order')

      get '/get_status_order/disable'

      expect(last_response.status).to eq 304
    end
  end

  describe 'enable get status order' do
    it 'enables the get status order response' do
      ResponseToggler.disable('get_status_order')

      get '/get_status_order/enable'

      expect(last_response).to be_ok

      expect(ResponseToggler.enabled?('get_status_order')).to be_truthy
    end

    it 'returns not modified if the get status order is already enabled' do
      ResponseToggler.enable('get_status_order')

      get '/get_status_order/enable'

      expect(last_response.status).to eq 304
    end
  end
end

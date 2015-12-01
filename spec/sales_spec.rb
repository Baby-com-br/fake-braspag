# encoding: utf-8
require 'spec_helper'
require 'active_support/core_ext/string/strip'

describe FakeBraspag::Sales do
  before do
    Order.connection.flushdb
    allow(SecureRandom).to receive(:uuid).and_return('a5f3181d-c2e2-4df9-a5b4-d8f6edf6bd51')
  end

  let(:credit_card_order_params) do
    {
      "MerchantOrderId" => "2014111703",
      "Customer" => {
        "Name" => "Comprador Teste"
      },
      "Payment" => {
        "Type" => "CreditCard",
        "Amount" => 15700,
        "Provider" => "Simulado",
        "Installments" => 1,
        "CreditCard" => {
          "CardNumber" => "1234123412341231",
          "SaveCard" => false,
          "Holder" => "Teste Holder",
          "ExpirationDate" => "12/2021",
          "SecurityCode" => "123",
          "Brand" => "Visa"
        }
      }
    }
  end

  let(:boleto_order_params) do
    {
      "MerchantOrderId" => "2014111706",
      "Customer" => {
        "Name" => "Comprador Teste"
      },
      "Payment" => {
        "Type" => "Boleto",
        "Amount" => 15700,
        "Provider" => "Simulado",
        "Address" => "Rua Teste",
        "BoletoNumber" => "123",
        "Assignor" => "Empresa Teste",
        "Demonstrative" => "Demonstrative Teste",
        "ExpirationDate" => "2015-01-05",
        "Identification" => "11884926754",
        "Instructions" => "Aceitar somente ate a data de vencimento, apos essa data juros de 1 porcento dia"
      }
    }
  end

  let(:payment_id) { 'fake-braspag.order.a5f3181d-c2e2-4df9-a5b4-d8f6edf6bd51' }

  describe 'authorization' do
    context 'with boleto' do
      it 'responds with a successful response' do
        post '/v2/sales/', boleto_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)).to eq(
          {
            "MerchantOrderId" => "2014111706",
            "Customer" =>
            {
              "Name" => "Comprador Teste"
            },
            "Payment" =>
            {
              "Instructions" => "Aceitar somente ate a data de vencimento, apos essa data juros de 1 por cento dia.",
              "ExpirationDate" => Date.tomorrow.strftime('%Y-%m-%d'),
              "Url" => "https =>//apisandbox.braspag.com.br/post/pagador/reenvia.asp/a5f3181d-c2e2-4df9-a5b4-d8f6edf6bd51",
              "BoletoNumber" => "123-2",
              "BarCodeNumber" => "00096629900000157000494250000000012300656560",
              "DigitableLine" => "00090.49420 50000.000013 23006.565602 6 62990000015700",
              "Assignor" => "Empresa Teste",
              "Address" => "Rua Teste",
              "Identification" => "11884926754",
              "PaymentId" => payment_id,
              "Type" => "Boleto",
              "Amount" => 15700,
              "ReceivedDate" => "2015-04-25 08:34:04",
              "Currency" => "BRL",
              "Country" => "BRA",
              "Provider" => "Simulado",
              "ReasonCode" => 0,
              "ReasonMessage" => "Successful",
              "Status" => 1,
              "Links" => []
            }
          })
      end

      it 'persists the order data' do
        post '/v2/sales/', boleto_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok

        order = Order.find('2014111706')
        expect(order.amount).to eq '157.0'
      end
    end

    context 'with valid credit card' do
      it 'responds with a successful response' do
        post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)).to eq(
        {
            "MerchantOrderId" => "2014111703",
            "Customer" => {
                "Name" => "Comprador Teste",
            },
            "Payment" => {
                "ServiceTaxAmount" => 0,
                "Installments" => 1,
                "Interest" => "ByMerchant",
                "Capture" => false,
                "Authenticate" => false,
                "CreditCard" => {
                    "CardNumber" => "123412******1231",
                    "Holder" => "Teste Holder",
                    "ExpirationDate" => "12/2021",
                    "SaveCard" => false,
                    "Brand" => "Visa"
                },
                "ProofOfSale" => "674532",
                "AcquirerTransactionId" => "0305023644309",
                "AuthorizationCode" => "123456",
                "PaymentId" => payment_id,
                "Type" => "CreditCard",
                "Amount" => 15700,
                "Installments" => 1,
                "ReceivedDate" => "2015-04-25 08:34:04",
                "Currency" => "BRL",
                "Country" => "BRA",
                "Provider" => "Simulado",
                "ReasonCode" => 0,
                "ReasonMessage" => "Successful",
                "Status" => 1,
                "ProviderReturnCode" => "4",
                "ProviderReturnMessage" => "Operation Successful",
                "Links" => []
            }
        })
      end

      it 'persists the order data' do
        post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok

        order = Order.find('2014111703')
        expect(order.amount).to eq '157.0'
      end
    end

    context 'with invalid credit card' do
      it 'responds with a error response' do
        credit_card_order_params['Payment']['CreditCard']['CardNumber'] = '4242424242424242'
        post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)).to eq(
        {
            "MerchantOrderId" => "2014111703",
            "Customer" => {
                "Name" => "Comprador Teste",
            },
            "Payment" => {
                "ServiceTaxAmount" => 0,
                "Installments" => 1,
                "Interest" => "ByMerchant",
                "Capture" => false,
                "Authenticate" => false,
                "CreditCard" => {
                    "CardNumber" => "424242******4242",
                    "Holder" => "Teste Holder",
                    "ExpirationDate" => "12/2021",
                    "SaveCard" => false,
                    "Brand" => "Visa"
                },
                "ProofOfSale" => "674532",
                "AcquirerTransactionId" => "0305023644309",
                "AuthorizationCode" => "123456",
                "PaymentId" => payment_id,
                "Type" => "CreditCard",
                "Amount" => 15700,
                "Installments" => 1,
                "ReceivedDate" => "2015-04-25 08:34:04",
                "Currency" => "BRL",
                "Country" => "BRA",
                "Provider" => "Simulado",
                "ReasonCode" => 7,
                "ReasonMessage" => "Denied",
                "Status" => 3,
                "ProviderReturnCode" => "2",
                "ProviderReturnMessage" => "Not Authorized",
                "Links" => []
            }
        })
      end

      it 'does not persist the order data' do
        credit_card_order_params['Payment']['CreditCard']['CardNumber'] = '4242424242424242'
        post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok
        expect(Order.count).to eq 0
      end
    end

    context "with save credit card option true" do
      it 'returns card token based on card number' do
        credit_card_order_params['Payment']['CreditCard']['SaveCard'] = true
        post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }

        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)['Payment']['CreditCard']['CardToken']).not_to be_nil
      end
    end
  end

  describe 'capture a sale' do
    context 'successful response' do
      before { allow(ResponseToggler).to receive(:enabled?).with('capture').and_return(true) }

      it 'responds with a success response' do
        put "/v2/sales/2014111703/capture"

        response = JSON.parse(last_response.body)

        expect(last_response).to be_ok
        expect(response).to eq("Status" => 2, "ReasonCode" => 0, "ReasonMessage" => "Successful", "ProviderReturnCode" => "6",
                               "ProviderReturnMessage" => "Operation Successful", "Links" => [])
      end
    end

    context 'failure response' do
      before { allow(ResponseToggler).to receive(:enabled?).with('capture').and_return(false) }

      it 'responds with an error response' do
        put "/v2/sales/2014111703/capture"

        response = JSON.parse(last_response.body)

        expect(last_response).to be_ok
        expect(response).to eq([{'Code' => 114, 'Message' => 'Error'}])
      end
    end
  end

  describe 'sale cancelation' do
    context 'success' do
      before { allow(ResponseToggler).to receive(:enabled?).with('void').and_return(true) }

      it 'responds with a success response' do
        put "/v2/sales/2014111703/void"

        response = JSON.parse(last_response.body)

        expect(last_response).to be_ok
        expect(response).to eq("Status" => 10, "ReasonCode" => 0, "ReasonMessage" => "Successful", "ProviderReturnCode" => "9",
          "ProviderReturnMessage" => "Operation Successful", "Links" => [])
      end
    end

    context 'failure' do
      before { allow(ResponseToggler).to receive(:enabled?).with('void').and_return(false) }

      it 'responds with an error response' do
        put "/v2/sales/2014111703/void"

        response = JSON.parse(last_response.body)

        expect(last_response).to be_ok
        expect(response).to eq([{'Code' => 114, 'Message' => 'Error'}])
      end
    end
  end

  describe 'search sale' do
    context 'success' do
      before { allow(ResponseToggler).to receive(:enabled?).with('get_sale').and_return(true) }

      context 'with credit card' do
        it 'responds with a success response' do
          post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }
          get "/v2/sales/2014111703"

          expect(last_response).to be_ok
          expect(JSON.parse(last_response.body)).to eq(
            {
              "MerchantOrderId"=>"2014111706",
              "Customer"=>{"Name"=>"Comprador Teste"},
              "Payment"=> {
                "ServiceTaxAmount"=>0,
                "Installments"=>1,
                "Interest"=>"ByMerchant",
                "Capture"=>false,
                "Authenticate"=>false,
                "CreditCard"=> {
                  "CardNumber"=>0,
                  "Holder"=>"Teste Holder",
                  "ExpirationDate"=>"12/2021",
                  "SaveCard"=>false,
                  "Brand"=>"Visa",
                  "CardToken"=>"TOKEN"
                },
                "ProofOfSale"=>"674532",
                "AcquirerTransactionId"=>"0305023644309",
                "AuthorizationCode"=>"123456",
                "PaymentId"=>"24bc8366-fc31-4d6c-8555-17049a836a07",
                "Type"=>"CreditCard",
                "Amount"=>15700,
                "ReceivedDate"=>"2015-04-25 08:34:04",
                "Currency"=>"BRL",
                "Country"=>"BRA",
                "Provider"=>"Simulado",
                "ReasonCode"=>0,
                "ReasonMessage"=>"Successful",
                "Status"=>1,
                "Links"=>[]
              }
            }
          )
        end
      end

      context 'with boleto' do
        it 'responds with a success response' do
          post '/v2/sales/', boleto_order_params.to_json, { 'Content-Type' => 'application/json' }
          get "/v2/sales/2014111706"

          expect(last_response).to be_ok
          expect(JSON.parse(last_response.body)).to eq({
            "MerchantOrderId" => "2014111706",
            "Customer" =>
            {
              "Name" => "Comprador Teste"
            },
            "Payment" =>
            {
              "Instructions" => "Aceitar somente ate a data de vencimento, apos essa data juros de 1 por cento dia.",
              "ExpirationDate" => Date.tomorrow.strftime('%Y-%m-%d'),
              "Url" => "https =>//apisandbox.braspag.com.br/post/pagador/reenvia.asp/a5f3181d-c2e2-4df9-a5b4-d8f6edf6bd51",
              "BoletoNumber" => "123-2",
              "BarCodeNumber" => "00096629900000157000494250000000012300656560",
              "DigitableLine" => "00090.49420 50000.000013 23006.565602 6 62990000015700",
              "Assignor" => "Empresa Teste",
              "Address" => "Rua Teste",
              "Identification" => "11884926754",
              "PaymentId" => payment_id,
              "Type" => "Boleto",
              "Amount" => 15700,
              "ReceivedDate" => "2015-04-25 08:34:04",
              "Currency" => "BRL",
              "Country" => "BRA",
              "Provider" => "Simulado",
              "ReasonCode" => 0,
              "ReasonMessage" => "Successful",
              "Status" => 1,
              "Links" => []
            }
          })
        end
      end
    end

    context 'failure' do
      before { allow(ResponseToggler).to receive(:enabled?).with('get_sale').and_return(false) }

      it 'responds with an error response' do
        get "/v2/sales/2014111706"

        response = JSON.parse(last_response.body)

        expect(last_response).to be_ok
        expect(response).to eq([{'Code' => 114, 'Message' => 'Error'}])
      end
    end
  end

  describe 'conciliate' do
    context 'with boleto' do
      context 'success' do
        it 'responds with a success response' do
          post '/v2/sales/', boleto_order_params.to_json, { 'Content-Type' => 'application/json' }
          put "/v2/sales/2014111706/conciliate"

          expect(last_response).to be_ok
          expect(JSON.parse(last_response.body)).to eq({
            "MerchantOrderId" => "2014111706",
            "Customer" =>
            {
              "Name" => "Comprador Teste"
            },
            "Payment" =>
            {
              "Instructions" => "Aceitar somente ate a data de vencimento, apos essa data juros de 1 por cento dia.",
              "ExpirationDate" => Date.tomorrow.strftime('%Y-%m-%d'),
              "Url" => "https =>//apisandbox.braspag.com.br/post/pagador/reenvia.asp/a5f3181d-c2e2-4df9-a5b4-d8f6edf6bd51",
              "BoletoNumber" => "123-2",
              "BarCodeNumber" => "00096629900000157000494250000000012300656560",
              "DigitableLine" => "00090.49420 50000.000013 23006.565602 6 62990000015700",
              "Assignor" => "Empresa Teste",
              "Address" => "Rua Teste",
              "Identification" => "11884926754",
              "PaymentId" => payment_id,
              "Type" => "Boleto",
              "Amount" => 15700,
              "ReceivedDate" => "2015-04-25 08:34:04",
              "Currency" => "BRL",
              "Country" => "BRA",
              "Provider" => "Simulado",
              "ReasonCode" => 0,
              "ReasonMessage" => "Successful",
              "Status" => 2,
              "Links" => []
            }
          })
        end
      end

      context 'failure' do
        context 'with an inexistent order' do
          it 'responds with an error response' do
            put "/v2/sales/111111111111111/conciliate"

            response = JSON.parse(last_response.body)

            expect(last_response).to be_ok
            expect(response).to eq([{'Code' => 114, 'Message' => 'Error'}])
          end
        end

        context 'with a credit card order' do
          it 'responds with an error response' do
            post '/v2/sales/', credit_card_order_params.to_json, { 'Content-Type' => 'application/json' }
            put "/v2/sales/2014111703/conciliate"

            response = JSON.parse(last_response.body)

            expect(last_response).to be_ok
            expect(response).to eq([{'Code' => 114, 'Message' => 'Error'}])
          end
        end

        context 'with conciliate toggle disabled' do
          before { allow(ResponseToggler).to receive(:enabled?).with('conciliate').and_return(false) }

          it 'responds with an error response' do
            put "/v2/sales/2014111706/conciliate"

            response = JSON.parse(last_response.body)

            expect(last_response).to be_ok
            expect(response).to eq([{'Code' => 114, 'Message' => 'Error'}])
          end
        end
      end
    end
  end
end

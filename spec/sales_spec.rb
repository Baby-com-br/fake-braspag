# encoding: utf-8

require 'spec_helper'
require 'active_support/core_ext/string/strip'

describe FakeBraspag::Sales do
  before do
    Order.connection.flushdb
  end

  let(:order_params) do
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
          "Holder" => "Teste Holder",
          "ExpirationDate" => "12/2021",
          "SecurityCode" => "123",
          "Brand" => "Visa"
        }
      }
    }
  end

  describe 'authorization' do
    context 'with valid credit card' do
      it 'responds with a successful response' do
        post '/v2/sales/', order_params

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
                "PaymentId" => "24bc8366-fc31-4d6c-8555-17049a836a07",
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
        post '/v2/sales/', order_params

        expect(last_response).to be_ok

        order = Order.find('2014111703')
        expect(order.amount).to eq '157.0'
      end
    end

    context 'with invalid credit card' do
      it 'responds with a error response' do
        order_params['Payment']['CreditCard']['CardNumber'] = '4242424242424242'
        post '/v2/sales/', order_params

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
                "PaymentId" => "24bc8366-fc31-4d6c-8555-17049a836a07",
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
        order_params['Payment']['CreditCard']['CardNumber'] = '4242424242424242'
        post '/v2/sales/', order_params

        expect(last_response).to be_ok
        expect(Order.count).to eq 0
      end
    end
  end
end

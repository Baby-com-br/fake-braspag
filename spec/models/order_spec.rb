# encoding: utf-8

require 'spec_helper'

describe Order do
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

  describe '.create' do
    it 'persists the object' do
      Order.create(order_params)

      expect(Order.count).to eq 1
    end

    it 'return false if it is already persisted' do
      Order.create(order_params)

      expect(Order.create(order_params)).to be_falsy
    end

    it 'return the order if persisted' do
      order = Order.create(order_params)

      expect(order).to be_a Order
      expect(order.id).to eq order_params['orderId']
    end
  end

  describe '.find!' do
    it 'gets the order from the database' do
      Order.create(order_params)
      order = Order.find!(order_params['orderId'])

      expect(order).to be_a Order
      expect(order.amount).to eq '18.36'
    end

    it 'raises error when not found on database' do
      expect {
        Order.find!(order_params['orderId'])
      }.to raise_error(Order::NotFoundError)
    end
  end

  describe '.find' do
    it 'gets the order from the database' do
      Order.create(order_params)
      order = Order.find(order_params['orderId'])

      expect(order).to be_a Order
      expect(order.amount).to eq '18.36'
    end

    it 'returns nil when not found on database' do
      expect(Order.find(order_params['orderId'])).to be_nil
    end
  end

  describe '#initialize' do
    it 'normalizes the amount' do
      order = Order.new(order_params)

      expect(order.amount).to eq '18.36'
    end
  end

  describe '#card_number' do
    it 'masks the card number' do
      order = Order.new(order_params)

      expect(order.card_number).to eq 'xxxxxxxxxxxx1111'
    end
  end

  describe '#save' do
    it 'persists the order' do
      order = Order.new(order_params)

      expect(order.save).to be_truthy

      persisted_order = Order.find(order.id)
      expect(persisted_order.amount).to eq order.amount
    end
  end

  describe '#reload' do
    it 'get the order attributes from the database' do
      Order.create(order_params)
      order = Order.new('orderId' => order_params['orderId'])

      expect(order.amount).to be_nil

      order.reload

      expect(order.amount).to eq '18.36'
    end

    it 'raises error when not found on database' do
      order = Order.new('orderId' => order_params['orderId'])

      expect(order.amount).to be_nil

      expect {
        order.reload
      }.to raise_error(Order::NotFoundError)
    end
  end

  describe '#authorize!' do
    context 'when the credit card is valid' do
      it 'marks the order as authorized' do
        order = Order.new(order_params)

        expect(order).not_to be_authorized

        order.authorize!

        expect(order).to be_authorized
      end

      it 'saves the change' do
        order = Order.new(order_params)

        expect(order).not_to be_authorized

        order.save

        order.authorize!

        order.reload

        expect(order).to be_authorized
      end
    end

    context 'when the credit card is invalid' do
      it 'raise a AuthorizationFailureError' do
        order = Order.new(order_params.merge('cardNumber' => '4242424242424242'))

        expect(order).not_to be_authorized

        expect {
          order.authorize!
        }.to raise_error(Order::AuthorizationFailureError)
      end

      it 'raise a AuthorizationFailureError when the order is persisted' do
        Order.create(order_params.merge('cardNumber' => '4242424242424242'))
        order = Order.find(order_params['orderId'])

        expect(order).not_to be_authorized

        expect {
          order.authorize!
        }.to raise_error(Order::AuthorizationFailureError)
      end
    end
  end

  describe '#capture!' do
    it 'marks the order as captured' do
      order = Order.new(order_params)
      expect(order).not_to be_captured

      order.capture!

      expect(order).to be_captured
    end

    it 'persists the change' do
      order = Order.new(order_params)
      expect(order).not_to be_captured

      order.save
      order.capture!
      order.reload

      expect(order).to be_captured
    end

    it 'records the partially captured amount' do
      order = Order.new(order_params)
      expect(order).not_to be_captured

      order.capture!('12,34')

      expect(order).to be_captured
      expect(order.captured_amount).to eq '12.34'
    end
  end

  describe '#authorized?' do
    it 'returns true if status is authorized' do
      order = Order.new(order_params.merge('status' => 'authorized'))

      expect(order).to be_authorized
    end

    it 'returns false if status is not authorized' do
      order = Order.new(order_params.merge('status' => 'captured'))

      expect(order).not_to be_authorized
    end
  end

  describe '#captured?' do
    it 'returns true if status is captured' do
      order = Order.new(order_params.merge('status' => 'captured'))

      expect(order).to be_captured
    end

    it 'returns false if status is not captured' do
      order = Order.new(order_params.merge('status' => 'authorized'))

      expect(order).not_to be_captured
    end
  end

  describe '#boleto?' do
    it 'returns true when order payment method is boleto' do
      order = Order.new(order_params.merge('paymentMethod' => 'Boleto'))

      expect(order).to be_boleto
    end

    it 'returns false when payment method is credit card' do
      order = Order.new(order_params.merge('paymentMethod' => 'CreditCard'))

      expect(order).not_to be_boleto
    end
  end

  describe '#method_missing' do
    it 'returns the value of the attribute key with the same name' do
      order = Order.new(order_params)

      expect(order.respond_to?(:holder)).to be_truthy
      expect(order.holder).to eq 'Rafael Franca'
    end

    it 'returns the value of the camelized key if it is on attribute' do
      order = Order.new(order_params)

      expect(order.respond_to?(:customer_name)).to be_truthy
      expect(order.customer_name).to eq 'Rafael França'
    end

    it 'raises NoMethodError if the key is not on the attributes hash' do
      order = Order.new(order_params)

      expect(order.respond_to?(:inexistent_method)).to be_falsy
      expect {
        order.inexistent_method
      }.to raise_error(NoMethodError, /inexistent_method/)
    end
  end
end

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
      'cardNumber' => '4242424242424242',
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
      expect(order['orderId']).to eq order_params['orderId']
    end
  end

  describe '.find' do
    it 'get the order from the database' do
      Order.create(order_params)
      order = Order.find(order_params['orderId'])

      expect(order).to be_a Order
      expect(order['amount']).to eq '18.36'
    end

    it 'raises error when not found on database' do
      expect {
        Order.find(order_params['orderId'])
      }.to raise_error(Order::NotFoundError)
    end
  end

  describe '.find!' do
    it 'get the order from the database' do
      Order.create(order_params)
      order = Order.find(order_params['orderId'])

      expect(order).to be_a Order
      expect(order['amount']).to eq '18.36'
    end

    it 'returns nil when not found on database' do
      expect(Order.find!(order_params['orderId'])).to be_nil
    end
  end

  describe '#captured' do
    it 'returns true if status is captured' do
      order = Order.new(order_params.merge('status' => 'captured'))

      expect(order).to be_captured
    end

    it 'returns false if status is not captured' do
      order = Order.new(order_params.merge('status' => 'authorized'))

      expect(order).not_to be_captured
    end
  end

  describe '#initialize' do
    it 'normalizes the amount' do
      order = Order.new(order_params)

      expect(order['amount']).to eq '18.36'
    end

    it 'masks the card number' do
      order = Order.new(order_params)

      expect(order['cardNumber']).to eq '************4242'
    end
  end

  describe '#save' do
    it 'persists the order' do
      order = Order.new(order_params)

      expect(order.save).to be_truthy

      persisted_order = Order.find(order['orderId'])
      expect(persisted_order['amount']).to eq order['amount']
    end
  end

  describe '#reload' do
    it 'get the order attributes from the database' do
      Order.create(order_params)
      order = Order.new('orderId' => order_params['orderId'])

      expect(order['amount']).to be_nil

      order.reload

      expect(order['amount']).to eq '18.36'
    end

    it 'raises error when not found on database' do
      order = Order.new('orderId' => order_params['orderId'])

      expect(order['amount']).to be_nil

      expect {
        order.reload
      }.to raise_error(Order::NotFoundError)
    end
  end

  describe '#capture!' do
    it 'marks the order as captured' do
      order = Order.new(order_params)

      expect(order).not_to be_captured

      order.capture!

      expect(order).to be_captured
    end

    it 'saves the change' do
      order = Order.new(order_params)

      expect(order).not_to be_captured

      order.save

      order.capture!

      order.reload

      expect(order).to be_captured
    end
  end
end

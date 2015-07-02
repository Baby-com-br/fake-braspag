require 'spec_helper'

describe SalePresenter do
  let(:params) { { 'amount' => '157.0', 'cardNumber' => '4111111111111111' } }
  let(:order) { Order.new(params) }

  subject(:sale) { SalePresenter.new(order) }

  describe '#card_number' do
    it 'returns nil when card number is not present' do
      params.merge!('cardNumber' => nil)
      expect(sale.card_number).to be_nil
    end

    it 'returns masked card number when card number is present' do
      expect(sale.card_number).to eq('411111******1111')
    end
  end

  describe '#amount' do
    it 'returns amount in braspag format' do
      expect(sale.amount).to eq(15700)
    end
  end

  describe '#reason_code' do
    it 'returns 0 when order is authorized' do
      order.authorize!
      expect(sale.reason_code).to eq(0)
    end

    it 'returns 7 when order is not authorized' do
      expect(sale.reason_code).to eq(7)
    end
  end

  describe '#reason_message' do
    it 'returns "Successful" when order is authorized' do
      order.authorize!
      expect(sale.reason_message).to eq('Successful')
    end

    it 'returns "Denied" when order is not authorized' do
      expect(sale.reason_message).to eq('Denied')
    end
  end

  describe '#status' do
    it 'returns 1 when order is authorized' do
      order.authorize!
      expect(sale.status).to eq(1)
    end

    it 'returns 3 when order is not authorized' do
      expect(sale.status).to eq(3)
    end
  end

  describe '#provider_return_code' do
    it 'returns "4" when order is authorized' do
      order.authorize!
      expect(sale.provider_return_code).to eq("4")
    end

    it 'returns "2" when order is not authorized' do
      expect(sale.provider_return_code).to eq("2")
    end
  end

  describe '#provider_return_message' do
    it 'returns "Successful" when order is authorized' do
      order.authorize!
      expect(sale.provider_return_message).to eq("Operation Successful")
    end

    it 'returns "Not Authorized" when order is not authorized' do
      expect(sale.provider_return_message).to eq("Not Authorized")
    end
  end
end

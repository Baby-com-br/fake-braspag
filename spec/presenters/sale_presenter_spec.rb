require 'spec_helper'

describe SalePresenter do
  let(:params) { { 'amount' => '157.0', 'cardNumber' => '4111111111111111', 'saveCard' => false } }
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

  describe '#captured_amount' do
    context 'when order is boleto paid' do
      it 'returns captured amount in braspag format' do
        order.pay_boleto!
        expect(sale.captured_amount).to eq(15700)
      end
    end

    context 'when order has not been asked to pay boleto' do
      it 'returns captured amount in braspag format' do
        expect(sale.captured_amount).to be_zero
      end
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
    context 'for a credit card order' do
      before { params.merge!({ 'paymentMethod' => 'CreditCard' }) }

      it 'returns 1 when order is authorized' do
        order.authorize!
        expect(sale.status).to eq(1)
      end

      it 'returns 3 when order is not authorized' do
        expect(sale.status).to eq(3)
      end
    end

    context 'for a boleto order' do
      before { params.merge!({ 'paymentMethod' => 'Boleto', 'boleto_status' => 'boleto_issued' }) }

      it 'returns 1 when boleto is issued' do
        expect(sale.status).to eq(1)
      end

      it 'returns 2 when boleto is paid' do
        order.pay_boleto!
        expect(sale.status).to eq(2)
      end
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

  describe '#card_token' do
    context 'when order has a saved card' do
      let(:params) { { 'amount' => '157.0', 'cardNumber' => '4111111111111111', 'saveCard' => true } }

      it 'returns a sha1 from card number' do
        expect(sale.card_token).to eq('68bfb396f35af3876fc509665b3dc23a0930')
      end
    end

    context 'when order has not a saved card' do
      let(:params) { { 'amount' => '157.0', 'cardNumber' => '4111111111111111', 'saveCard' => false } }

      it 'returns nil' do
        expect(sale.card_token).to be_nil
      end
    end
  end

  describe '#save_card' do
    it 'returns order saveCard attribute' do
      expect(sale.save_card).to be_falsey
    end
  end
end

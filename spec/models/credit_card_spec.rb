require 'spec_helper'

describe FakeBraspag::CreditCard do
  describe '#save' do
    it 'generates a JustClickKey UUID when it has a valid RequestId' do
      card = described_class.new('RequestId' => 'bf4616ea-448a-4a15-9590-ce1163f3ad50')
      allow(SecureRandom).to receive(:uuid).and_return('bf4616ea-448a-4a15-9590-ce1163f3ad50')

      expect(card.save).to be_truthy

      expect(card.just_click_key).to eq('bf4616ea-448a-4a15-9590-ce1163f3ad50')
    end

    it 'does not generate a JustClickKey when it has no RequestId' do
      card = described_class.new('NotRequestId' => 'Not Request Id')

      expect(card.save).to be_falsy
    end
  end

  describe '#just_click_shop' do
    it 'sets a success status and extra attributes accordingly' do
      card = described_class.new('RequestId' => 'bf4616ea-448a-4a15-9590-ce1163f3ad50')

      expect(card.just_click_shop).to be_truthy

      expect(card.success).to be true
      expect(card.aquirer_transaction_id).to eq '123456789'
      expect(card.authorization_code).to eq '012345'
      expect(card.status).to be 0
      expect(card.return_code).to be 0
      expect(card.return_message).to eq 'Autorizado com sucesso'
    end

    it 'does nothing when it has no RequestId' do
      card = described_class.new('NotRequestId' => 'Not Request Id')

      expect(card.just_click_shop).to be_falsy
      expect(card).not_to respond_to(:status)
    end
  end

  describe '#request_id' do
    it 'accepts optional brackets' do
      card = described_class.new('RequestId' => '{bf4616ea-448a-4a15-9590-ce1163f3ad50}')
      expect(card.correlation_id).to eq 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    end

    it 'downcases the UUID' do
      card = described_class.new('RequestId' => 'BF4616EA-448A-4A15-9590-CE1163F3AD50')
      expect(card.correlation_id).to eq 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    end

    it 'is nil when there is no RequestId' do
      expect(described_class.new({}).correlation_id).to be_nil
    end
  end

  describe '#correlation_id' do
    it 'is the given RequestId UUID' do
      card = described_class.new('RequestId' => 'BF4616EA-448A-4A15-9590-CE1163F3AD50')
      expect(card.correlation_id).to eq 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    end
  end

  describe '#method_missing' do
    it 'returns the value of the attribute key with the same name' do
      credit_card = described_class.new('Amount' => '12.34')

      expect(credit_card.respond_to?(:amount)).to be_truthy
      expect(credit_card.amount).to eq '12.34'
    end

    it 'returns the value of the camelized key if it is on attribute' do
      credit_card = described_class.new('CustomerName' => 'John')

      expect(credit_card.respond_to?(:customer_name)).to be_truthy
      expect(credit_card.customer_name).to eq 'John'
    end

    it 'raises NoMethodError if the key is not on the attributes hash' do
      credit_card = described_class.new('CardHolder' => 'John Doe')

      expect(credit_card.respond_to?(:inexistent_method)).to be_falsy
      expect {
        credit_card.inexistent_method
      }.to raise_error(NoMethodError, /inexistent_method/)
    end
  end
end

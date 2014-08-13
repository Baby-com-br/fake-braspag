require 'spec_helper'

describe FakeBraspag::CreditCard do
  describe '#valid?' do
    it 'is true when it has a RequestId' do
      expect(described_class.new('RequestId' => 'bf4616ea-448a-4a15-9590-ce1163f3ad50')).to be_valid
    end

    it 'is false when it has no RequestId' do
      expect(described_class.new('NotRequestId' => 'Not Request Id')).not_to be_valid
    end
  end

  describe '#correlation_id' do
    it 'is the given RequestId UUID' do
      expect(
        described_class.new('RequestId' => 'BF4616EA-448A-4A15-9590-CE1163F3AD50').correlation_id
      ).to eq 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    end

    it 'accepts optional brackets' do
      expect(
        described_class.new('RequestId' => '{bf4616ea-448a-4a15-9590-ce1163f3ad50}').correlation_id
      ).to eq 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    end

    it 'is nil when there is no RequestId' do
      expect(described_class.new({}).correlation_id).to be_nil
    end
  end

  describe '#just_click_key' do
    it 'is a randomly generated UUID' do
      allow(SecureRandom).to receive(:uuid).and_return('bf4616ea-448a-4a15-9590-ce1163f3ad50')
      expect(described_class.new('').just_click_key).to eq 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    end
  end
end

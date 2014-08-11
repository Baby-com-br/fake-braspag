require 'spec_helper'

describe FakeBraspag::CreditCard do
  describe '#valid?' do
    it 'is true when its xml has a valid RequestId' do
      expect(described_class.new('...<tns:RequestId>{Some UUID}</...')).to be_valid
    end

    it 'is false when its xml has no RequestId' do
      expect(described_class.new('...<tns:RequestId></...')).not_to be_valid
    end
  end

  describe '#correlation_id' do
    it 'is the downcased RequestId from he xml source' do
      expect(
        described_class.new('...<tns:RequestId>Some UUID</...').correlation_id
      ).to eq 'some uuid'
    end

    it 'accepts optional brackets' do
      expect(
        described_class.new('...<tns:RequestId>{Some UUID}</...').correlation_id
      ).to eq 'some uuid'
    end

    it 'is nil when there is no RequestId in the xml source' do
      expect(described_class.new('').correlation_id).to be_nil
    end
  end

  describe '#just_click_key' do
    it 'is a randomly generated UUID' do
      allow(SecureRandom).to receive(:uuid).and_return('some uuid')
      expect(described_class.new('').just_click_key).to eq 'some uuid'
    end
  end
end

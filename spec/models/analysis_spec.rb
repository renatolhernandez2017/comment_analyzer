require 'rails_helper'

RSpec.describe Analysis, type: :model do
  describe '.mean' do
    it 'returns 0 for empty array' do
      expect(Analysis.mean([])).to eq(0)
    end

    it 'returns 0 for array with nils only' do
      expect(Analysis.mean([nil, nil])).to eq(0)
    end

    it 'returns mean of array' do
      expect(Analysis.mean([1, 2, 3])).to eq(2)
    end

    it 'ignores nil values' do
      expect(Analysis.mean([1, nil, 3])).to eq(2)
    end

    it 'returns 0 for array with sum <= 0' do
      expect(Analysis.mean([-1, -1])).to eq(0)
    end
  end

  describe '.median' do
    it 'returns 0 for empty array' do
      expect(Analysis.median([])).to eq(0)
    end

    it 'returns 0 for array with nils only' do
      expect(Analysis.median([nil, nil])).to eq(0)
    end

    it 'returns median for odd-length array' do
      expect(Analysis.median([1, 3, 2])).to eq(2)
    end

    it 'returns median for even-length array' do
      expect(Analysis.median([1, 2, 3, 4])).to eq(2.5)
    end
  end

  describe '.std_dev' do
    it 'returns 0 for empty array' do
      expect(Analysis.std_dev([])).to eq(0)
    end

    it 'returns 0 for array with nils only' do
      expect(Analysis.std_dev([nil, nil])).to eq(0)
    end

    it 'returns standard deviation' do
      result = Analysis.std_dev([1, 2, 3])
      expect(result).to be_within(0.001).of(0.816)
    end

    it 'ignores nil values' do
      result = Analysis.std_dev([1, nil, 3])
      expect(result).to be_within(0.001).of(1.0)
    end
  end
end

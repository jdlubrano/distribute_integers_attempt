require 'byebug'
require 'rspec'
require_relative '../itemizer'

RSpec.describe Itemizer do
  describe 'self.distribute_to' do
    let(:itemizer) { Itemizer.new(array) }

    let(:array) do
      [{ quantity: 1, total: 1, id: 1 }]
    end

    subject { itemizer.distribute(amount) }

    context 'when amount is zero' do
      let(:amount) { 0 }

      it { is_expected.to contain_exactly(*array) }
    end

    context 'worst case under-rounding' do
      let(:amount) { 3 }

      let(:array) do
        [
          { quantity: 1, total: 1, id: 1 },
          { quantity: 1, total: 2, id: 2 },
          { quantity: 1, total: 3, id: 3 }
        ]
      end

      it 'should distribute the amount evenly' do
        expected = array.map do |item|
          item.tap { |it| it[:total] += 1 }
        end

        is_expected.to contain_exactly(*expected)
      end
    end

    context 'worst case over-rounding' do
      let(:amount) { 3 }

      let(:array) do
        [
          { quantity: 1, total: 1, id: 1 },
          { quantity: 1, total: 1, id: 2 }
        ]
      end

      it 'should not add more than the amount' do
        expected = [
          { quantity: 1, total: 2, id: 1 },
          { quantity: 1, total: 3, id: 2 }
        ]

        is_expected.to contain_exactly(*expected)
      end
    end

    context 'when quantities are not even' do
      let(:amount) { 3 }

      let(:array) do
        [
          { quantity: 3, total: 1, id: 1 },
          { quantity: 1, total: 2, id: 2 }
        ]
      end

      it 'distributes the amount weighted by quantity' do
        expected = [
          { quantity: 3, total: 3, id: 1 },
          { quantity: 1, total: 3, id: 2 }
        ]

        is_expected.to contain_exactly(*expected)
      end

      it 'distributes between all of the items' do
        expected = [
          { quantity: 3, total: 4, id: 1 },
          { quantity: 1, total: 3, id: 2 }
        ]

        expect(itemizer.distribute(4)).to contain_exactly(*expected)
      end
    end
  end
end

require 'rails_helper'

describe Cart, type: :model do
  context 'validations' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include('must be greater than or equal to 0')
    end
  end

  describe '#add_product' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10) }

    it 'adds a new product to the cart' do
      expect {
        cart.add_product(product, 2)
      }.to change { cart.cart_items.count }.by(1)

      expect(cart.total_price).to eq(20)
    end

    it 'increments quantity if product already exists' do
      cart.add_product(product, 1)
      cart.add_product(product, 2)

      item = cart.cart_items.find_by(product: product)
      expect(item.quantity).to eq(3)
      expect(cart.total_price).to eq(30)
    end

    it 'raises error when trying to add zero quantity' do
      expect { cart.add_product(product, 0) }
        .to raise_error(ArgumentError, 'Quantity must be positive')
    end

    it 'raises error when trying to add negative quantity' do
      expect { cart.add_product(product, -5) }
        .to raise_error(ArgumentError, 'Quantity must be positive')
    end
  end

  describe '#remove_product' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 5) }

    it 'removes the product and recalculates total' do
      cart.add_product(product, 2) # total = 10
      expect {
        cart.remove_product(product)
      }.to change { cart.cart_items.count }.by(-1)

      expect(cart.total_price).to eq(0)
    end

    it 'returns nil if product not in cart' do
      other_product = create(:product)
      expect(cart.remove_product(other_product)).to be_nil
    end
  end
end
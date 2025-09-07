require 'rails_helper'

describe Cart, type: :model do
  context 'validations' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include('must be greater than or equal to 0')
    end
  end

  describe '#mark_as_abandoned' do
    let(:cart) { create(:cart, last_interaction_at: 3.hours.ago) }

    it 'marks the cart as abandoned if inactive' do
      expect { cart.mark_as_abandoned }
        .to change { cart.reload.abandoned? }
        .from(false).to(true)
    end
  end

  describe '#remove_if_abandoned' do
    let!(:cart) { create(:cart, last_interaction_at: 7.days.ago, abandoned: true) }

    it 'removes the cart if expired and abandoned' do
      expect { cart.remove_if_abandoned }
        .to change { Cart.count }.by(-1)
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

    it 'returns false if product not in cart' do
      other_product = create(:product)
      expect(cart.remove_product(other_product)).to be_falsey
    end
  end

  describe '#as_json' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 15) }

    it 'serializes the cart with products and prices' do
      cart.add_product(product, 2)

      json = cart.as_json
      expect(json[:id]).to eq(cart.id)
      expect(json[:total_price]).to eq('30.0')
      expect(json[:products].first).to include(
        id: product.id,
        name: product.name,
        quantity: 2,
        unit_price: '15.0',
        total_price: '30.0'
      )
    end
  end
end

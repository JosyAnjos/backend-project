require 'rails_helper'

describe CartService, type: :service do
  describe '.mark_abandoned_carts' do
    it 'marks inactive carts as abandoned' do
      active_cart = create(:cart, last_interaction_at: 1.hour.ago)
      inactive_cart = create(:cart, last_interaction_at: 4.hours.ago)

      described_class.mark_abandoned_carts

      expect(active_cart.reload.abandoned).to be_falsey
      expect(inactive_cart.reload.abandoned).to be_truthy
    end
  end

  describe '.remove_expired_carts' do
    it 'removes expired abandoned carts' do
      non_expired_cart = create(:cart, abandoned: true, last_interaction_at: 6.days.ago)
      expired_cart = create(:cart, abandoned: true, last_interaction_at: 8.days.ago)

      expect {
        described_class.remove_expired_carts
      }.to change(Cart, :count).by(-1)

      expect(Cart.find_by(id: non_expired_cart.id)).to be_present
      expect(Cart.find_by(id: expired_cart.id)).to be_nil
    end
  end
end

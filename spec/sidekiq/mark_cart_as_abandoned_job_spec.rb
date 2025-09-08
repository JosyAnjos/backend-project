require 'rails_helper'

describe MarkCartAsAbandonedJob, type: :job do
  describe "#perform" do
    let!(:user) { create(:user) }
    let!(:active_cart) { create(:cart, user: user, last_interaction_at: 1.hour.ago) }
    let!(:abandoned_cart) { create(:cart, user: user, last_interaction_at: 4.hours.ago) }
    let!(:old_abandoned_cart) { create(:cart, user: user, abandoned: true, last_interaction_at: 8.days.ago) }

    it 'marks inactive carts as abandoned' do
      expect {
        described_class.new.perform
        abandoned_cart.reload
      }.to change { abandoned_cart.abandoned }.from(false).to(true)
    end

    it 'removes old abandoned carts' do
      expect {
        described_class.new.perform
      }.to change(Cart, :count).by(-1)
    end

    it 'does not affect active carts' do
      expect {
        described_class.new.perform
        active_cart.reload
      }.not_to change { active_cart.abandoned }
    end

    context 'when an error occurs' do
      before do
        allow(CartService).to receive(:mark_abandoned_carts).and_raise(StandardError, 'Something went wrong')
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with('Failed to process abandoned carts: Something went wrong')
        expect { described_class.new.perform }.to raise_error(StandardError, 'Something went wrong')
      end

      it 'raises the error' do
        expect { described_class.new.perform }.to raise_error(StandardError, 'Something went wrong')
      end
    end
  end
end
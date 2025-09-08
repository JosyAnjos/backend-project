class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.where("last_interaction_at < ?", Cart::CART_ABANDONMENT_THRESHOLD_HOURS.hours.ago).update_all(abandoned: true)

    Cart.where(abandoned: true).where("last_interaction_at < ?", Cart::CART_REMOVAL_THRESHOLD_DAYS.days.ago).destroy_all
  end
end
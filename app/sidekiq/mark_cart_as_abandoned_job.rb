class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.where("last_interaction_at < ?", Rails.application.config.cart_abandonment_threshold_hours.hours.ago).update_all(abandoned: true)

    Cart.where(abandoned: true).where("last_interaction_at < ?", Rails.application.config.cart_removal_threshold_days.days.ago).destroy_all
  end
end
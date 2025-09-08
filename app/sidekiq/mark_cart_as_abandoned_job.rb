class MarkCartAsAbandonedJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  def perform
    CartService.mark_abandoned_carts
    CartService.remove_expired_carts
  rescue => e
    Rails.logger.error("Failed to process abandoned carts: #{e.message}")
    raise e
  end
end

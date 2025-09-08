class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    CartService.mark_abandoned_carts
    CartService.remove_expired_carts
  end
end
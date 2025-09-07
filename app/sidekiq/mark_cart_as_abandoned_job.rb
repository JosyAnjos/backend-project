class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.inactive.update_all(abandoned: true)
    Cart.abandoned.expired.destroy_all
  end
end

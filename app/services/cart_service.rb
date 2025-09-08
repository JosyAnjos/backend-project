class CartService
  def self.mark_abandoned_carts
    Cart.inactive.where(abandoned: false).in_batches.update_all(abandoned: true)
  end

  def self.remove_expired_carts
    Cart.abandoned.expired.in_batches.destroy_all
  end
end
class CartService
  def self.mark_abandoned_carts
    Cart.inactive.where(abandoned: false).update_all(abandoned: true)
  end

  def self.remove_expired_carts
    Cart.abandoned.expired.destroy_all
  end
end
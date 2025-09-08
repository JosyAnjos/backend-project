class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  after_save :recalculate_cart_total
  after_destroy :recalculate_cart_total

  private

  def recalculate_cart_total
    cart.recalculate_total!
  end
end
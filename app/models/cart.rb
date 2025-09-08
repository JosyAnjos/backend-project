class Cart < ApplicationRecord
  CART_ABANDONMENT_THRESHOLD_HOURS = 3
  CART_REMOVAL_THRESHOLD_DAYS = 7

  belongs_to :user
  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0, allow_nil: true

  scope :inactive, -> { where('last_interaction_at < ?', CART_ABANDONMENT_THRESHOLD_HOURS.hours.ago) }
  scope :abandoned, -> { where(abandoned: true) }
  scope :expired, -> { where('last_interaction_at < ?', CART_REMOVAL_THRESHOLD_DAYS.days.ago) }

  def touch_interaction!
    update!(last_interaction_at: Time.current)
  end

  def add_product(product, quantity = 1)
    raise ArgumentError, 'Quantity must be positive' if quantity.to_i <= 0

    item = cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + quantity.to_i
    item.save!
    item
  end

  def remove_product(product)
    item = cart_items.find_by(product: product)
    item&.destroy
  end

  def recalculate_total!
    update!(total_price: cart_items.joins(:product).sum('cart_items.quantity * products.price'))
  end
end
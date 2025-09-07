class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0, allow_nil: true

  scope :inactive, ->  { where('last_interaction_at < ?', 3.hours.ago) }
  scope :abandoned, -> { where(abandoned: true) }
  scope :expired,   -> { where('last_interaction_at < ?', 7.days.ago) }

  def mark_as_abandoned
    if last_interaction_at.present? && last_interaction_at < 3.hours.ago
      update(abandoned: true)
    end
  end

  def remove_if_abandoned
    destroy if abandoned? && last_interaction_at.present? && last_interaction_at < 7.days.ago
  end

  def abandoned?
    abandoned
  end

  def touch_interaction!
    update!(last_interaction_at: Time.current)
  end

  def add_product(product, quantity = 1)
    item = cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + quantity.to_i
    item.save!
    recalculate_total!
    item
  end

  def remove_product(product)
    item = cart_items.find_by(product: product)
    return unless item

    item.destroy
    recalculate_total!
  end

  def recalculate_total!
    total = cart_items
              .joins(:product)
              .sum(Arel.sql('cart_items.quantity * products.price'))
    update!(total_price: total)
  end

  # Delega para o serializer e mantem compatibilidade com testes que chamam Cart#as_json
  def as_json(_opts = {})
    CartSerializer.new(self).as_json
  end
end

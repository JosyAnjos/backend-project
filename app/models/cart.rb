class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def mark_as_abandoned
    update(abandoned: true) if last_interaction_at < 2.hours.ago
  end

  def remove_if_abandoned
    destroy if abandoned? && last_interaction_at < 7.days.ago
  end
end

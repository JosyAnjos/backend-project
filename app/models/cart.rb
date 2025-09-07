class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

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
end

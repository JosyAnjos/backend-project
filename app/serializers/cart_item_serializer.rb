class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :unit_price, :total_price

  def id
    product.id
  end

  def name
    product.name
  end

  def unit_price
    product.price.to_s
  end

  def total_price
    (object.quantity * product.price).to_s
  end

  private

  def product
    object.product
  end
end

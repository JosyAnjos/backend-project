class CartItemSerializer
  def initialize(cart_item)
    @cart_item = cart_item
  end

  def as_json(*)
    {
      id: @cart_item.product.id,
      name: @cart_item.product.name,
      quantity: @cart_item.quantity,
      unit_price: @cart_item.product.price.to_s,
      total_price: (@cart_item.quantity * @cart_item.product.price).to_s
    }
  end
end

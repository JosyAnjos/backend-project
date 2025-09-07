class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def as_json(*)
    {
      id: @cart.id,
      total_price: @cart.total_price.to_s,
      products: @cart.cart_items.map do |item|
        CartItemSerializer.new(item).as_json
      end
    }
  end
end

class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: format_cart(@cart)
  end

  def add_item
    product = Product.find(cart_params[:product_id])
    cart_item = @cart.cart_items.find_or_initialize_by(product: product)

    cart_item.quantity = (cart_item.quantity || 0) + cart_params[:quantity].to_i
    cart_item.save!

    @cart.total_price = @cart.cart_items.sum { |item| item.quantity * item.product.price }
    @cart.save!

    render json: format_cart(@cart), status: :created
  end

  def remove_item
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
    if cart_item
      cart_item.destroy
      @cart.total_price = @cart.cart_items.sum { |item| item.quantity * item.product.price }
      @cart.save!
      render json: format_cart(@cart)
    else
      render json: { error: "Product not found in cart" }, status: :not_found
    end
  end

  private

  def set_cart
    if session[:cart_id]
      @cart = Cart.find(session[:cart_id])
    else
      @cart = Cart.create!
      session[:cart_id] = @cart.id
    end
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def format_cart(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_s,
          total_price: (item.quantity * item.product.price).to_s
        }
      end,
      total_price: cart.total_price.to_s
    }
  end
end

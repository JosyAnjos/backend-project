class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: CartSerializer.new(@cart).as_json
  end

  def add_item
    product = Product.find(cart_params[:product_id])
    @cart.add_product(product, cart_params[:quantity].to_i)

    render json: CartSerializer.new(@cart).as_json, status: :created
  end

  def remove_item
    if @cart.remove_product(params[:product_id])
      render json: CartSerializer.new(@cart).as_json
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
end

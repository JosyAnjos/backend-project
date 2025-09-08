class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: @cart, include: :cart_items
  end

  def add_item
    product = Product.find(cart_params[:product_id])
    cart_item = @cart.add_product(product, cart_params[:quantity])

    render json: @cart, include: :cart_items, status: :created
  end

  def remove_item
    product = Product.find(params[:product_id])
    @cart.remove_product(product)

    render json: @cart, include: :cart_items
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

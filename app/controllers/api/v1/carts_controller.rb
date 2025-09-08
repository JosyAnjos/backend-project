module Api
  module V1
    class CartsController < ApplicationController
      before_action :authenticate_user_from_token
      before_action :require_authentication
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

      def require_authentication
        render json: { error: "Unauthorized" }, status: :unauthorized unless user_signed_in?
      end

      def set_cart
        @cart = current_user.cart || current_user.create_cart!
      end

      def cart_params
        params.permit(:product_id, :quantity)
      end
    end
  end
end
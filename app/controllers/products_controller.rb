class ProductsController < ApplicationController
  before_action :authenticate_user_from_token
  before_action :require_authentication
  before_action :set_product, only: %i[ show update destroy ]

  def index
    @products = Product.all

    render json: @products
  end

  def show
    render json: @product
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  def destroy
    @product.destroy!
  end

  private
    def require_authentication
      render json: { error: "Unauthorized" }, status: :unauthorized unless user_signed_in?
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price)
    end
end

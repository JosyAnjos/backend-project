require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /add_items" do
    let(:cart)     { Cart.create! }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 5.0) }

    context 'when adding a new product to the cart' do
      before do
        post '/cart/add_items', params: { cart_id: cart.id, product_id: product1.id, quantity: 1 }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the cart with the new product' do
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["products"][0]["id"]).to eq(product1.id)
        expect(json_response["products"][0]["quantity"]).to eq(1)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response["total_price"].to_f).to eq(10.0)
      end
    end

    context 'when the product already is in the cart' do
      before do
        cart.cart_items.create!(product: product1, quantity: 1)
        post '/cart/add_items', params: { cart_id: cart.id, product_id: product1.id, quantity: 2 }
      end

      it 'updates the quantity of the existing item in the cart' do
        json_response = JSON.parse(response.body)
        expect(json_response["products"][0]["quantity"]).to eq(3)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response["total_price"].to_f).to eq(30.0)
      end
    end

    context 'with multiple products' do
      before do
        post '/cart/add_items', params: { cart_id: cart.id, product_id: product1.id, quantity: 2 }
        post '/cart/add_items', params: { cart_id: cart.id, product_id: product2.id, quantity: 3 }
      end

      it 'returns the cart with all products' do
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(2)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response["total_price"].to_f).to eq(35.0)
      end

      it 'returns the correct product details' do
        json_response = JSON.parse(response.body)
        product1_response = json_response["products"].find { |p| p["id"] == product1.id }
        product2_response = json_response["products"].find { |p| p["id"] == product2.id }

        expect(product1_response["quantity"]).to eq(2)
        expect(product1_response["unit_price"]).to eq('10.0')
        expect(product1_response["total_price"]).to eq('20.0')

        expect(product2_response["quantity"]).to eq(3)
        expect(product2_response["unit_price"]).to eq('5.0')
        expect(product2_response["total_price"]).to eq('15.0')
      end
    end
  end
end

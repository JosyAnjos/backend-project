require 'rails_helper'

describe '/cart', type: :request do
  let(:product1) { create(:product, price: 10.0) }
  let(:product2) { create(:product, price: 5.0) }

  describe 'GET /cart' do
    context 'when cart does not exist' do
      it 'creates a new cart and returns it' do
        get '/cart'
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to be_present
        expect(json_response['products']).to be_empty
      end
    end

    context 'when cart exists' do
      let(:cart) { create(:cart, total_price: 20.0) }

      before do
        cart.cart_items.create!(product: product1, quantity: 2)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        get '/cart'
      end

      it 'returns the cart details' do
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(cart.id)
        expect(json_response['products'].size).to eq(1)
        expect(json_response['total_price']).to eq('20.0')
      end
    end
  end

  describe 'POST /cart' do
    context 'when adding a new product to the cart' do
      before do
        post '/cart', params: { product_id: product1.id, quantity: 1 }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the cart with the new product' do
        json_response = JSON.parse(response.body)
        expect(json_response['products'].size).to eq(1)
        expect(json_response['products'][0]['id']).to eq(product1.id)
        expect(json_response['products'][0]['quantity']).to eq(1)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response['total_price'].to_f).to eq(10.0)
      end
    end

    context 'when the product already is in the cart' do
      let(:cart) { create(:cart) }

      before do
        cart.cart_items.create!(product: product1, quantity: 1)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        post '/cart', params: { product_id: product1.id, quantity: 2 }
      end

      it 'updates the quantity of the existing item in the cart' do
        json_response = JSON.parse(response.body)
        expect(json_response['products'][0]['quantity']).to eq(3)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response['total_price'].to_f).to eq(30.0)
      end
    end
  end

  describe 'DELETE /cart/:product_id' do
    let(:cart) { create(:cart) }

    before do
      cart.cart_items.create!(product: product1, quantity: 2)
      cart.cart_items.create!(product: product2, quantity: 3)
      allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
    end

    context 'when product exists in cart' do
      it 'removes the product from the cart' do
        expect {
          delete "/cart/#{product1.id}"
        }.to change { cart.reload.cart_items.count }.by(-1)
      end

      it 'returns a successful response' do
        delete "/cart/#{product1.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'recalculates the total price' do
        delete "/cart/#{product1.id}"
        json_response = JSON.parse(response.body)
        expect(json_response['total_price'].to_f).to eq(15.0)
      end
    end

    context 'when product does not exist in cart' do
      it 'returns a not found response' do
        delete '/cart/999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

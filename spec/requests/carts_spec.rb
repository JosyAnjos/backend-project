require 'rails_helper'

describe '/api/v1/cart', type: :request do
  let(:product1) { create(:product, price: 10.0) }
  let(:product2) { create(:product, price: 5.0) }
  let(:user)     { create(:user) }

  let(:auth_headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe 'GET /cart' do
    context 'when cart does not exist for the user' do
      it 'creates a new cart for the user and returns it' do
        get '/api/v1/cart', headers: auth_headers
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to be_present
        expect(json_response['cart_items']).to be_empty
        expect(user.reload.cart).to be_present
      end
    end

    context 'when cart exists for the user' do
      let!(:cart) { create(:cart, user: user, total_price: 20.0) }

      before do
        cart.cart_items.create!(product: product1, quantity: 2)
        get '/api/v1/cart', headers: auth_headers
      end

      it 'returns the cart details' do
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(cart.id)
        expect(json_response['cart_items'].size).to eq(1)
        expect(json_response['total_price']).to eq('20.0')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/cart'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /cart' do
    context 'when adding a new product to the cart' do
      before do
        post '/api/v1/cart', params: { product_id: product1.id, quantity: 1 }, headers: auth_headers
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the cart with the new product' do
        json_response = JSON.parse(response.body)
        expect(json_response['cart_items'].size).to eq(1)
        expect(json_response['cart_items'][0]['id']).to eq(product1.id)
        expect(json_response['cart_items'][0]['quantity']).to eq(1)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response['total_price'].to_f).to eq(10.0)
      end
    end

    context 'when the product already is in the cart' do
      let!(:cart) { create(:cart, user: user) }

      before do
        cart.cart_items.create!(product: product1, quantity: 1)
        post '/api/v1/cart', params: { product_id: product1.id, quantity: 2 }, headers: auth_headers
      end

      it 'updates the quantity of the existing item in the cart' do
        json_response = JSON.parse(response.body)
        expect(json_response['cart_items'][0]['quantity']).to eq(3)
      end

      it 'calculates the total price correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response['total_price'].to_f).to eq(30.0)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        post '/api/v1/cart', params: { product_id: product1.id, quantity: 1 }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /cart/:product_id' do
    let!(:cart) { create(:cart, user: user) }

    before do
      cart.cart_items.create!(product: product1, quantity: 2)
      cart.cart_items.create!(product: product2, quantity: 3)
    end

    context 'when product exists in cart' do
      it 'removes the product from the cart' do
        expect {
          delete "/api/v1/cart/#{product1.id}", headers: auth_headers
        }.to change { cart.reload.cart_items.count }.by(-1)
      end

      it 'returns a successful response' do
        delete "/api/v1/cart/#{product1.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'recalculates the total price' do
        delete "/api/v1/cart/#{product1.id}", headers: auth_headers
        json_response = JSON.parse(response.body)
        expect(json_response['total_price'].to_f).to eq(15.0)
      end
    end

    context 'when product does not exist in cart' do
      it 'returns a not found response' do
        delete '/api/v1/cart/999', headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        delete "/api/v1/cart/#{product1.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

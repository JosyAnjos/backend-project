require "rails_helper"

describe Api::V1::CartsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/api/v1/cart').to route_to('api/v1/carts#show')
    end

    it 'routes to #add_item via POST' do
      expect(post: '/api/v1/cart').to route_to('api/v1/carts#add_item')
    end

    it 'routes to #remove_item via DELETE' do
      expect(delete: '/api/v1/cart/1').to route_to('api/v1/carts#remove_item', product_id: '1')
    end
  end
end

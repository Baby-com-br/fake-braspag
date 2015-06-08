module FakeBraspag
  class Orders < Sinatra::Base
    post '/GetDadosPedido' do
      order = Order.find(params['orderId'])

      if order
        if ResponseToggler.enabled?('get_status_order')
          builder :get_status_order_success, {}, { order: order }
        else
          builder :get_status_order_failure, {}, { order: order }
        end
      else
        builder :get_status_order_not_available
      end
    end
  end
end

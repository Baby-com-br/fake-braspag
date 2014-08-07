module FakeBraspag
  class Webservices < Sinatra::Base
    post '/Authorize' do
      order = Order.new params

      begin
        order.authorize!

        builder :authorize_success, {}, { order: order }
      rescue Order::AuthorizationFailureError
        builder :authorize_failure, {}, { order: order }
      end
    end

    post '/Capture' do
      order = Order.find(params['orderId'])

      if order
        if ResponseToggler.enabled?('capture')
          order.capture!
          builder :capture_success, {}, { order: order }
        else
          builder :capture_failure, {}, { order: order }
        end
      else
        builder :capture_not_available
      end
    end

    post '/CapturePartial' do
      order = Order.find(params['orderId'])
      amount = params['captureAmount']

      if order
        if ResponseToggler.enabled?('capture_partial')
          order.capture!(amount)
          builder :capture_partial_success, {}, { order: order }
        else
          builder :capture_partial_failure, {}, { order: order }
        end
      else
        builder :capture_partial_not_found
      end
    end
  end
end

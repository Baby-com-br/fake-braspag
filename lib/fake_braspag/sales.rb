module FakeBraspag
  class Sales < Sinatra::Base
    post '/' do
      @order = Order.new parsed_params

      begin
        @order.authorize!

        jbuilder :sales_authorize
      rescue Order::AuthorizationFailureError
        jbuilder :sales_authorize
      end
    end

    private

    def parsed_params
      {
        'orderId' => params['MerchantOrderId'],
        'amount' => (params['Payment']['Amount'].to_i / 100.0).to_s,
        'cardNumber' => params['Payment']['CreditCard']['CardNumber']
      }
    end
  end
end

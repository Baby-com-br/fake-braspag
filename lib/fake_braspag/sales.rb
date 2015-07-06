module FakeBraspag
  class Sales < Sinatra::Base
    post '/' do
      order = Order.new parsed_params

      begin
        order.authorize!
        @sale = SalePresenter.new(order)

        jbuilder :sales_authorize
      rescue Order::AuthorizationFailureError
        @sale = SalePresenter.new(order)
        jbuilder :sales_authorize
      end
    end

    put '/:PaymentId/void' do
      if ResponseToggler.enabled?('sale_cancelation')
        jbuilder :sales_cancel
      else
        jbuilder :sales_cancel_failure
      end
    end

    private

    def parsed_params
      @params = JSON.parse(request.body.read)

      {
        'orderId' => @params['MerchantOrderId'],
        'amount' => (@params['Payment']['Amount'].to_i / 100.0).to_s,
        'cardNumber' => @params['Payment']['CreditCard']['CardNumber'],
        'saveCard' => @params['Payment']['CreditCard']['SaveCard']
      }
    end
  end
end

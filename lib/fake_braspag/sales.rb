module FakeBraspag
  class Sales < Sinatra::Base
    get '/:PaymentId' do
      if ResponseToggler.enabled?('get_sale')
        jbuilder :get_sale
      else
        jbuilder :get_sale_failure
      end
    end

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

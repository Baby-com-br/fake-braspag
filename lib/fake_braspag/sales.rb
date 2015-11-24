module FakeBraspag
  class Sales < Sinatra::Base
    get '/:PaymentId' do
      if ResponseToggler.enabled?('get_sale')
        order = Order.find!(params[:PaymentId])
        @sale = SalePresenter.new(order)
        jbuilder order.PaymentMethod == 'CreditCard' ? :get_credit_card_sale : :get_boleto_sale
      else
        jbuilder :get_sale_failure
      end
    end

    post '/' do
      order = Order.new parsed_params

      begin
        order.authorize!
        @sale = SalePresenter.new(order)

        jbuilder order.PaymentMethod == 'CreditCard' ? :sales_authorize : :sales_boleto
      rescue Order::AuthorizationFailureError
        @sale = SalePresenter.new(order)
        jbuilder order.PaymentMethod == 'CreditCard' ? :sales_authorize : :sales_boleto
      end
    end

    put '/:PaymentId/capture' do
      if ResponseToggler.enabled?('capture')
        jbuilder :sales_capture
      else
        jbuilder :sales_capture_failure
      end
    end

    put '/:PaymentId/void' do
      if ResponseToggler.enabled?('void')
        jbuilder :sales_cancel
      else
        jbuilder :sales_cancel_failure
      end
    end

    private

    def parsed_params
      @params = JSON.parse(request.body.read)
      common_params =  {
          'orderId' => @params['MerchantOrderId'],
          'amount' => (@params['Payment']['Amount'].to_i / 100.0).to_s
      }

      if @params['Payment']['Type'] == 'CreditCard'
        common_params.merge({
          'paymentMethod' => 'CreditCard',
          'cardNumber' => @params['Payment']['CreditCard']['CardNumber'],
          'saveCard' => @params['Payment']['CreditCard']['SaveCard']
        })
      else
        common_params.merge({'paymentMethod' => 'Boleto'})
      end
    end
  end
end

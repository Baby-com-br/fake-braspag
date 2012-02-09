# encoding: utf-8

module FakeBraspag
  AUTHORIZE_URI    = "/webservices/pagador/Pagador.asmx/Authorize"
  CAPTURE_URI      = "/webservices/pagador/Pagador.asmx/Capture"

  module Authorize
    module Status
      AUTHORIZED = "1"
      DENIED     = "2"
    end
  end

  module Capture
    module Status
      CAPTURED = "0"
      DENIED   = "2"
    end
  end

  class App < Sinatra::Base
    private
    def card_number
      params[:cardNumber]
    end

    def authorize_request
      params[:order_id]    = params[:orderId]
      params[:card_number] = params[:cardNumber]
      params[:status]      = order_status
      params[:type]        = PaymentType::CREDIT_CARD
      Order.save_order params
    end

    def amount_for_get_dados_pedido
      Order.orders[params[:numeroPedido]].nil? ? "" : Order.orders[params[:numeroPedido]][:amount]
    end

    def capture_request
      Order.change_status params[:orderId], order_status
    end

    def authorize_with_success?
      authorize_status == Authorize::Status::AUTHORIZED || 
        [CreditCard::AUTHORIZE_AND_CAPTURE_OK, CreditCard::AUTHORIZE_AND_CAPTURE_DENIED].include?(card_number)
    end

    def capture_with_success?
      capture_status == Capture::Status::CAPTURED || card_number == CreditCard::AUTHORIZE_AND_CAPTURE_OK
    end

    def authorize_status
      case card_number
      when CreditCard::AUTHORIZE_DENIED; Authorize::Status::DENIED
      when CreditCard::AUTHORIZE_AND_CAPTURE_OK; Capture::Status::CAPTURED
      when CreditCard::AUTHORIZE_AND_CAPTURE_DENIED; Capture::Status::DENIED
      when CreditCard::AUTHORIZE_OK, CreditCard::CAPTURE_OK, CreditCard::CAPTURE_DENIED; Authorize::Status::AUTHORIZED
      end
    end

    def order_status
      case card_number
      when CreditCard::CAPTURE_DENIED, CreditCard::AUTHORIZE_DENIED, CreditCard::AUTHORIZE_AND_CAPTURE_DENIED; Order::Status::CANCELLED
      when CreditCard::AUTHORIZE_OK; Order::Status::PENDING
      when CreditCard::CAPTURE_OK, CreditCard::AUTHORIZE_AND_CAPTURE_OK; Order::Status::PAID
      end
    end

    def capture_status
      return nil if Order.orders[params[:orderId]].nil? 
      case Order.orders[params[:orderId]][:card_number]
      when CreditCard::CAPTURE_OK, CreditCard::AUTHORIZE_AND_CAPTURE_OK; Capture::Status::CAPTURED
      when CreditCard::CAPTURE_DENIED, CreditCard::AUTHORIZE_AND_CAPTURE_DENIED; Capture::Status::DENIED
      end
    end
  end

  module CreditCard
    AUTHORIZE_OK                 = "5340749871433512"
    AUTHORIZE_DENIED             = "5558702121154658"
    AUTHORIZE_AND_CAPTURE_OK     = "5326107541057732"
    AUTHORIZE_AND_CAPTURE_DENIED = "5430442567033801"
    CAPTURE_OK                   = "5277253663231678"
    CAPTURE_DENIED               = "5473598178407565"

    def self.registered(app)
      app.post AUTHORIZE_URI do
        authorize_request if authorize_with_success?
        capture_request   if capture_with_success?
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>5</amount>
            <message>Transaction Successful</message>
            <authorisationNumber>733610</authorisationNumber>
            <returnCode>7</returnCode>
            <status>#{authorize_status}</status>
            <transactionId>#{params[:orderId]}</transactionId>
          </PagadorReturn>
        EOXML
      end

      app.post CAPTURE_URI do
        capture_request if capture_with_success?
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>2</amount>
            <message>Approved</message>
            <returnCode>0</returnCode>
            <status>#{capture_status}</status>
          </PagadorReturn>
        EOXML
      end
    end
  end
end

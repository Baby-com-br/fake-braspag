# encoding: utf-8

module FakeBraspag
  AUTHORIZE_URI    = "/webservices/pagador/Pagador.asmx/Authorize"
  CAPTURE_URI      = "/webservices/pagador/Pagador.asmx/Capture"

  module Authorize
    module Status
      AUTHORIZED = "1"
      DENIED     = "2"
    end
    
    module ReturnCode
      AUTHORIZED = "7"
      DENIED     = "2"
    end
    
    module Message
      AUTHORIZED = "Authorization OK"
      DENIED     = "Authorization FAILED"
    end
  end

  module Capture
    module Status
      CAPTURED = "0"
      DENIED   = "2"
    end
    
    module ReturnCode
      CAPTURED = "50"
      DENIED     = "51"
    end
    
    module Message
      CAPTURED = "Capture OK"
      DENIED     = "Capture FAILED"
    end
  end

  class App < Sinatra::Base
    private
    def credit_card_amount
      Order.order(credit_card_order_id)[:amount]
    end
    
    def authorize_number
      case authorize_status
      when Authorize::Status::AUTHORIZED, Capture::Status::CAPTURED
        credit_card_order_id
      else
        ""
      end
    end
    
    def authorize_message
      case authorize_status
      when Authorize::Status::AUTHORIZED, Capture::Status::CAPTURED
        Authorize::Message::AUTHORIZED
      else
        Authorize::Message::DENIED
      end
    end
    
    def auhtorize_return_code
      case authorize_status
      when Authorize::Status::AUTHORIZED, Capture::Status::CAPTURED
        Authorize::ReturnCode::AUTHORIZED
      else
        Authorize::ReturnCode::DENIED
      end
    end
    
    def authorize_status
      case credit_card_number
      when CreditCard::AUTHORIZE_DENIED, CreditCard::AUTHORIZE_AND_CAPTURE_DENIED; Authorize::Status::DENIED
      when CreditCard::AUTHORIZE_AND_CAPTURE_OK; Capture::Status::CAPTURED
      else
        Authorize::Status::AUTHORIZED
      end
    end
    
    def credit_card_order_id
      params[:orderId]
    end
    
    def credit_card_number
      params[:cardNumber]
    end
    
    def authorize_order_status
      case credit_card_number
      when CreditCard::AUTHORIZE_AND_CAPTURE_OK
        Order::Status::PAID
      when CreditCard::AUTHORIZE_DENIED, CreditCard::AUTHORIZE_AND_CAPTURE_DENIED
        Order::Status::CANCELLED
      else
        Order::Status::PENDING
      end
    end

    def authorize_request
      params[:order_id]    = credit_card_order_id
      params[:card_number] = credit_card_number
      params[:status]      = authorize_order_status
      params[:type]        = PaymentType::CREDIT_CARD
      Order.save_order params
    end
    
    def capture_credit_card_number
      Order.order(credit_card_order_id)[:card_number]
    end
    
    def capture_message
      case capture_credit_card_number
      when CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK
        Capture::Message::CAPTURED
      else
        Capture::Message::DENIED
      end
    end
    
    def capture_return_code
      case capture_credit_card_number
      when CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK
        Capture::ReturnCode::CAPTURED
      else
        Capture::ReturnCode::DENIED
      end
    end
    
    def capture_status
      case capture_credit_card_number
      when CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK
        Capture::Status::CAPTURED
      else
        Capture::Status::DENIED
      end
    end

    def capture_request
      case capture_credit_card_number
      when CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK
        Order.change_status credit_card_order_id, Order::Status::PAID
      else
        Order.change_status credit_card_order_id, Order::Status::CANCELLED
      end
    end
  end

  module CreditCard
    AUTHORIZE_DENIED                   = "5558702121154658"
    AUTHORIZE_AND_CAPTURE_OK           = "5326107541057732"
    AUTHORIZE_AND_CAPTURE_DENIED       = "5430442567033801"
    AUTHORIZE_AND_CAPTURE_LATER_OK     = "5340749871433512"
    AUTHORIZE_AND_CAPTURE_LATER_DENIED = "5277253663231678"

    def self.registered(app)
      app.post AUTHORIZE_URI do
        authorize_request
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>#{credit_card_amount}</amount>
            <message>#{authorize_message}</message>
            <authorisationNumber>#{authorize_number}</authorisationNumber>
            <returnCode>#{auhtorize_return_code}</returnCode>
            <status>#{authorize_status}</status>
            <transactionId>#{credit_card_order_id}</transactionId>
          </PagadorReturn>
        EOXML
      end

      app.post CAPTURE_URI do
        capture_request
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>#{credit_card_amount}</amount>
            <message>#{capture_message}</message>
            <returnCode>#{capture_return_code}</returnCode>
            <status>#{capture_status}</status>
          </PagadorReturn>
        EOXML
      end
    end
  end
end

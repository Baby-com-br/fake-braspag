require "bundler/setup"

Bundler.require 

module FakeBraspag
  AUTHORIZE_URI    = "/webservices/pagador/Pagador.asmx/Authorize"
  CAPTURE_URI      = "/webservices/pagador/Pagador.asmx/Capture"
  DADOS_PEDIDO_URI = "/webservices/pagador/pedido.asmx/GetDadosPedido"

  module CreditCards
    AUTHORIZE_OK                 = "5340749871433512"
    AUTHORIZE_DENIED             = "5558702121154658"
    AUTHORIZE_AND_CAPTURE_OK     = "5326107541057732"
    AUTHORIZE_AND_CAPTURE_DENIED = "5430442567033801"
    CAPTURE_OK                   = "5277253663231678"
    CAPTURE_DENIED               = "5473598178407565"
  end

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

  module DadosPedido
    module Status
      PENDING   = "1"
      PAID      = "3"
      CANCELLED = "4"
    end
  end

  class App < Sinatra::Base
    class << self
      def authorized_requests
        @authorized_requests ||= {}
      end

      def captured_requests
        @captured_requests ||= []
      end

      def authorize_request(params)
        authorized_requests[params[:order_id]] = {:card_number => params[:card_number], :amount => params[:amount]}
      end

      def capture_request(order_id)
        captured_requests << order_id
      end

      def clear_authorized_requests
        authorized_requests.clear
      end

      def clear_captured_requests
        captured_requests.clear
      end
    end

    post AUTHORIZE_URI do
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
          <transactionId>#{params[:order_id]}</transactionId>
        </PagadorReturn>
      EOXML
    end

    post CAPTURE_URI do
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

    get DADOS_PEDIDO_URI do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <CodigoAutorizacao>885796</CodigoAutorizacao>
        <CodigoPagamento>18</CodigoPagamento>
        <FormaPagamento>American Express 2P</FormaPagamento>
        <NumeroParcelas>1</NumeroParcelas>
        <Status>#{dados_pedido_status}</Status>
        <Valor>#{amount_for_get_dados_pedido}</Valor>
        <DataPagamento>7/8/2011 1:19:38 PM</DataPagamento>
        <DataPedido>7/8/2011 1:06:06 PM</DataPedido>
        <TransId>398591</TransId>
        <BraspagTid>5a1d4463-1d11-4571-a877-763aba0ef7ff</BraspagTid>
      </DadosPedido>
      EOXML
    end

    private
    def card_number
      params[:card_number]
    end

    def authorize_request
      self.class.authorize_request params
    end

    def amount_for_get_dados_pedido
      authorized_requests[params[:numeroPedido]].nil? ? "" : authorized_requests[params[:numeroPedido]][:amount]
    end

    def capture_request
      self.class.capture_request params[:order_id]
    end

    def authorize_with_success?
      authorize_status == Authorize::Status::AUTHORIZED || 
        [CreditCards::AUTHORIZE_AND_CAPTURE_OK, CreditCards::AUTHORIZE_AND_CAPTURE_DENIED].include?(card_number)
    end

    def capture_with_success?
      capture_status == Capture::Status::CAPTURED || card_number == CreditCards::AUTHORIZE_AND_CAPTURE_OK
    end

    def authorize_status
      case card_number
      when CreditCards::AUTHORIZE_DENIED; Authorize::Status::DENIED
      when CreditCards::AUTHORIZE_AND_CAPTURE_OK; Capture::Status::CAPTURED
      when CreditCards::AUTHORIZE_AND_CAPTURE_DENIED; Capture::Status::DENIED
      when CreditCards::AUTHORIZE_OK, CreditCards::CAPTURE_OK, CreditCards::CAPTURE_DENIED; Authorize::Status::AUTHORIZED
      end
    end

    def authorized_requests
      self.class.authorized_requests
    end

    def captured_requests
      self.class.captured_requests
    end

    def capture_status
      return nil if authorized_requests[params[:order_id]].nil? 
      case authorized_requests[params[:order_id]][:card_number]
      when CreditCards::CAPTURE_OK, CreditCards::AUTHORIZE_AND_CAPTURE_OK; Capture::Status::CAPTURED
      when CreditCards::CAPTURE_DENIED, CreditCards::AUTHORIZE_AND_CAPTURE_DENIED; Capture::Status::DENIED
      end
    end

    def dados_pedido_status
      return nil if authorized_requests[params[:numeroPedido]].nil?
      if captured_requests.include? params[:numeroPedido]
        DadosPedido::Status::PAID 
      else
        case authorized_requests[params[:numeroPedido]][:card_number]
        when CreditCards::AUTHORIZE_OK, CreditCards::AUTHORIZE_AND_CAPTURE_OK
          DadosPedido::Status::PENDING
        else
          DadosPedido::Status::CANCELLED
        end
      end
    end

    configure do
      set :show_expections, false
    end
  end
end

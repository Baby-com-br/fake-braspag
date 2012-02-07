require "bundler/setup"

Bundler.require 

$:.unshift File.dirname(File.expand_path(__FILE__)) + "/lib"

module FakeBraspag
  AUTHORIZE_URI = "/webservices/pagador/Pagador.asmx/Authorize"
  CAPTURE_URI   = "/webservices/pagador/Pagador.asmx/Capture"

  module CreditCards
    AUTHORIZE_OK = "5340749871433512"
  end

  module Authorize
    module Status
      AUTHORIZED = "1"
    end
  end

  class App < Sinatra::Base
    class << self
      attr_reader :received_requests

      def save_request(order_id, card_number)
        @received_requests ||= {}
        @received_requests[order_id] = card_number
      end
    end

    post AUTHORIZE_URI do
      save_request
      <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>5</amount>
          <message>Transaction Successful</message>
          <authorisationNumber>733610</authorisationNumber>
          <returnCode>7</returnCode>
          <status>#{Authorize::Status::AUTHORIZED}</status>
          <transactionId>#{params[:order_id]}</transactionId>
        </PagadorReturn>
      EOXML
    end

    def save_request
      self.class.save_request params[:order_id], params[:card_number]
    end

    configure do
      set :show_expections, false
    end
  end
end

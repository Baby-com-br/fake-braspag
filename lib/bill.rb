# encoding: utf-8
module FakeBraspag
  BILL_URL = "/webservices/pagador/Boleto.asmx/CreateBoleto"

  class App < Sinatra::Base
    private
    def bill_amount
      bill_ok? ? params[:amount].gsub(",", ".") : ""
    end
    
    def bill_ok?
      params[:paymentMethod] == Bill::PAYMENT_METHOD_OK
    end
    
    def bill_status
      bill_ok? ? Bill::Status::SUCCESS : Bill::Status::ERROR
    end
    
    def bill_return_code
      bill_ok? ? Bill::ReturnCode::SUCCESS : Bill::ReturnCode::ERROR
    end
  end

  module Bill
    module ReturnCode
      SUCCESS = "0"
      ERROR   = "1"
    end

    module Status
      SUCCESS = "0"
      ERROR   = ""
    end

    PAYMENT_METHOD_OK    = "ok"
    PAYMENT_METHOD_ERROR = "error"

    def self.registered(app)
      app.post BILL_URL do
        require 'ruby-debug'
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
          <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>#{bill_amount}</amount>
            <boletoNumber>#{params[:orderId]}</boletoNumber>
            <expirationDate>2100-12-31T00:00:00-03:00</expirationDate>
            <url>https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=12341234-1234-1234-1234-123412341234</url>
            <returnCode>#{bill_return_code}</returnCode>
            <status>#{bill_status}</status>
          </PagadorBoletoReturn>
        EOXML
      end
    end
  end
end


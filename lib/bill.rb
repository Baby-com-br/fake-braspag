# encoding: utf-8
module FakeBraspag
  GENERATE_BILL_URL = "/webservices/pagador/Boleto.asmx/CreateBoleto"
  BILL_URL = "/boleto"

  class App < Sinatra::Base
    private
    def bill_amount
      bill_ok? ? params[:amount].gsub(",", ".") : ""
    end
    
    def bill_ok?
      params[:paymentMethod] != Bill::PAYMENT_METHOD_ERROR
    end
    
    def bill_status
      bill_ok? ? Bill::Status::SUCCESS : Bill::Status::ERROR
    end
    
    def bill_return_code
      bill_ok? ? Bill::ReturnCode::SUCCESS : Bill::ReturnCode::ERROR
    end
    
    def bill_url
      url = request.scheme + "://" + request.host_with_port + "/boleto?Id_Transacao=" + params[:orderId]
      bill_ok? ? url : ""
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
      app.post GENERATE_BILL_URL do
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
          <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>#{bill_amount}</amount>
            <boletoNumber>#{params[:orderId]}</boletoNumber>
            <expirationDate>2100-12-31T00:00:00-03:00</expirationDate>
            <url>#{bill_url}</url>
            <returnCode>#{bill_return_code}</returnCode>
            <status>#{bill_status}</status>
          </PagadorBoletoReturn>
        EOXML
      end
      
      app.get BILL_URL do
        erb :bill
      end
    end
  end
end


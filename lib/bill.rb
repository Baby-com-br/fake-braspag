# encoding: utf-8
module FakeBraspag
  BILL_URL = "/webservices/pagador/Boleto.asmx/CreateBoleto"

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
      
    end
  end
end

# OK
# <?xml version="1.0" encoding="utf-8"?>
# <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#                      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
#                      xmlns="https://www.pagador.com.br/webservice/pagador">
#     <amount>300</amount>
#     <boletoNumber>70031</boletoNumber>
#     <expirationDate>2100-12-31T00:00:00-03:00</expirationDate>
#     <url>https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=12341234-1234-1234-1234-123412341234</url>
#     <returnCode>0</returnCode>
#     <status>0</status>
# </PagadorBoletoReturn>
#
# Erro
# <?xml version="1.0" encoding="utf-8"?>
#        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
#                             xmlns="https://www.pagador.com.br/webservice/pagador">
#          <amount xsi:nil="true" />
#          <expirationDate xsi:nil="true" />
#          <returnCode>1</returnCode>
#          <message>Invalid merchantId</message>
#          <status xsi:nil="true" />
#        </PagadorBoletoReturn>

require 'spec_helper'

describe FakeBraspag::Application do
  it 'responds to' do
    post '/webservices/pagador/Pagador.asmx/Capture'

    expect(last_response.body).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>20.01</amount>
  <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:257575054    VALOR:        20,01@ESTAB:040187624 DINDA COM BR          @24.07.14-16:27:33 TERM:RO128278/528374@AUTORIZACAO EMISSOR: 642980           @CODIGO PRE-AUTORIZACAO: 52978         @CARTAO: xxxxxxxxxxxx4242              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
  <returnCode>0</returnCode>
  <transactionId>257575054</transactionId>
</PagadorReturn>
    XML
  end
end

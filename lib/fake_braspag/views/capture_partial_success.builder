xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.PagadorReturn 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns' => 'https://www.pagador.com.br/webservice/pagador' do
  xml.amount order.captured_amount
  xml.message(
    "F                 REDE                 @" +
    "    CONFIRMACAO DE PRE-AUTORIZACAO    @" +
    "COMPR:247524362    VALOR:       #{params['captureAmount']}@" +
    "                NUM. PARCELA:      01@" +
    "ESTAB:040187624 FAKE BRASPAG          @" +
    "24.07.14-16:38:47 TERM:RO128278/531425@" +
    "AUTORIZACAO EMISSOR: 214111           @" +
    "CODIGO PRE-AUTORIZACAO: 14111         @" +
    "CARTAO: #{order.card_number}              @" +
    "     RECONHECO E PAGAREI A DIVIDA     @" +
    "          AQUI REPRESENTADA           @@@" +
    "     ____________________________     @@"
  )
  xml.returnCode 0
  xml.status 0
end

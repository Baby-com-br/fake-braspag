xml.instruct!
xml.PagadorReturn 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns' => 'https://www.pagador.com.br/webservice/pagador' do
  xml.amount order.amount
  xml.message "F                 REDE                 @" +
    "    CONFIRMACAO DE PRE-AUTORIZACAO    @" +
    "COMPR:257575054    VALOR:        #{order.amount}@" +
    "ESTAB:040187624 FAKE BRASPAG          @" +
    "24.07.14-16:27:33 TERM:RO128278/528374@" +
    "AUTORIZACAO EMISSOR: 642980           @" +
    "CODIGO PRE-AUTORIZACAO: 52978         @" +
    "CARTAO: #{order.card_number}              @" +
    "     RECONHECO E PAGAREI A DIVIDA     @" +
    "          AQUI REPRESENTADA           @@@" +
    "     ____________________________     @@"
  xml.returnCode 0
  xml.status 0
  xml.transactionId 257575054
end

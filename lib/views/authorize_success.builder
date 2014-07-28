xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.PagadorReturn 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns' => 'https://www.pagador.com.br/webservice/pagador' do
  xml.amount order['amount']
  xml.authorisationNumber 505369
  xml.message 'Operation Successful'
  xml.returnCode 4
  xml.status 1
  xml.transactionId '0728043853882'
end

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.PagadorReturn 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns' => 'https://www.pagador.com.br/webservice/pagador' do
  xml.amount nil, 'xsi:nil' => true
  xml.message "Transaction specified was not found in the database"
  xml.returnCode 1003
  xml.status nil, 'xsi:nil' => true
end

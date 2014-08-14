xml.instruct!
xml.PagadorReturn 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns' => 'https://www.pagador.com.br/webservice/pagador' do
  xml.amount nil, 'xsi:nil' => true
  xml.message "Transaction not available for capture. Please check the status of this transaction."
  xml.returnCode 1111
  xml.status nil, 'xsi:nil' => true
end

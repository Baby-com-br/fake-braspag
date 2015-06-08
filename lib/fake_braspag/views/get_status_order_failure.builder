xml.instruct!
xml.DadosPedido 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns' => 'http://www.pagador.com.br/' do
  xml.CodigoAutorizacao 123456
  xml.CodigoPagamento 42
  xml.FormaPagamento "Redecard Webservice"
  xml.NumeroParcelas 1
  xml.Status 4
  xml.Valor order.amount
  xml.DataPagamento "6/8/2015 10:09:57 AM"
  xml.DataPedido "6/8/2015 10:09:45 AM"
  xml.TransId 654321
  xml.BraspagTid "3144c006-2e50-4e79-bd15-215ac073f87c"
end

xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
  xml.soap :Body do
    xml.JustClickShopResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
      xml.JustClickShopResult do
        xml.Success card.success
        xml.CorrelationId card.correlation_id
        xml.BraspagTransactionId '00000000-0000-0000-0000-000000000000'
        xml.AquirerTransactionId card.aquirer_transaction_id
        xml.Amount card.amount
        xml.AuthorizationCode card.authorization_code
        xml.Status card.status
        xml.ReturnCode card.return_code
        xml.ReturnMessage card.return_message
      end
    end
  end
end


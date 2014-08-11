xml.instruct! :xml, version: '1.0', encoding: 'utf-8'
xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
  xml.soap :Body do
    xml.SaveCreditCardResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
      xml.SaveCreditCardResult do
        xml.JustClickKey card.just_click_key
        xml.CorrelationId card.correlation_id
        xml.Success true
      end
    end
  end
end

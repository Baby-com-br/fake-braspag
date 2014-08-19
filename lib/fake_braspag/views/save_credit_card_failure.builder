xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
  xml.soap :Body do
    xml.SaveCreditCardResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
      xml.SaveCreditCardResult do
        xml.Success false
        xml.CorrelationId card.correlation_id || '00000000-0000-0000-0000-000000000000'
        xml.ErrorReportCollection do
          xml.ErrorReport do
            xml.ErrorCode 732
            xml.ErrorMessage 'SaveCreditCardRequestId can not be null'
          end
        end
        xml.JustClickKey '00000000-0000-0000-0000-000000000000'
      end
    end
  end
end

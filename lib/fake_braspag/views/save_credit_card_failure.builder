xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
  xml.soap :Body do
    xml.SaveCreditCardResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
      xml.SaveCreditCardResult do
        xml.Success false
        xml.CorrelationId '00000000-0000-0000-0000-000000000000'
        xml.ErrorReportCollection do
          xml.ErrorReport do
            xml.ErrorCode error_code
            xml.ErrorMessage error_message
          end
        end
        xml.JustClickKey '00000000-0000-0000-0000-000000000000'
      end
    end
  end
end

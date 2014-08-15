xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
  xml.soap :Body do
    xml.JustClickShopResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
      xml.JustClickShopResult do
        xml.Success false
        xml.CorrelationId '00000000-0000-0000-0000-000000000000'
        xml.AquirerTransactionId '???'
        xml.Amount 0
        xml.Status 2
        xml.ReturnCode '???'
        xml.ReturnMessage '???'

        xml.ErrorReportCollection do
          xml.ErrorReport do
            xml.ErrorCode error_code
            xml.ErrorMessage error_message
          end
        end
      end
    end
  end
end

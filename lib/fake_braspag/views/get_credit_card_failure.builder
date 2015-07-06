xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope',
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
    xml.soap :Body do
      xml.GetCreditCardResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
          xml.GetCreditCardResult do
            xml.Success false
            xml.CorrelationId 'xsi:nil' => true
            xml.ErrorReportCollection do
              xml.ErrorReport do
                xml.ErrorCode 701
                xml.ErrorMessage "Merchant key can not be null"
              end
            end
          end
        end
    end
  end

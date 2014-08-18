xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
  xml.soap :Body do
    xml.JustClickShopResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
      xml.JustClickShopResult do
        xml.Success false
        xml.CorrelationId card.correlation_id || '00000000-0000-0000-0000-000000000000'

        xml.ErrorReportCollection do
          xml.ErrorReport do
            xml.ErrorCode 726
            xml.ErrorMessage 'Credit card expired'
          end
        end

        xml.BraspagTransactionId '00000000-0000-0000-0000-000000000000'
        xml.Amount 0
        xml.Status 'xsi:nil' => true
      end
    end
  end
end

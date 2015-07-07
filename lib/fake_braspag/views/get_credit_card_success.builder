xml.instruct!
xml.soap :Envelope, 'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope',
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
    xml.soap :Body do
      xml.GetCreditCardResponse 'xmlns' => 'http://www.cartaoprotegido.com.br/WebService/' do
        xml.GetCreditCardResult do
          xml.Success true
          xml.CorrelationId 'xsi:nil' => true
          xml.ErrorReportCollection nil
          xml.CardHolder "TESTE HOLDER"
          xml.CardNumber "0000000000000001"
          xml.CardExpiration "12/2021"
          xml.MaskedCardNumber "000000******0001"
        end
      end
    end
  end

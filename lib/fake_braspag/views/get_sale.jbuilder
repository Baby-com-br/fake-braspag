json.MerchantOrderId "2014111706"
json.Customer do |customer|
  customer.Name "Comprador Teste"
end
json.Payment do |payment|
  payment.ServiceTaxAmount 0
  payment.Installments 1
  payment.Interest "ByMerchant"
  payment.Capture false
  payment.Authenticate false

  payment.CreditCard do |credit_card|
    credit_card.CardNumber 0
    credit_card.Holder "Teste Holder"
    credit_card.ExpirationDate "12/2021"
    credit_card.SaveCard false
    credit_card.Brand "Visa"
    credit_card.CardToken "TOKEN"
  end

  payment.ProofOfSale "674532"
  payment.AcquirerTransactionId "0305023644309"
  payment.AuthorizationCode "123456"
  payment.PaymentId "24bc8366-fc31-4d6c-8555-17049a836a07"
  payment.Type "CreditCard"
  payment.Amount 15700
  payment.Installments 1
  payment.ReceivedDate "2015-04-25 08:34:04"
  payment.Currency "BRL"
  payment.Country "BRA"
  payment.Provider "Simulado"
  payment.ReasonCode 0
  payment.ReasonMessage "Successful"
  payment.Status 1
  payment.Links []
end

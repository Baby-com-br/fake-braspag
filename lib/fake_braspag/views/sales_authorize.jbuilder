json.MerchantOrderId @order.id
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
    credit_card.CardNumber '%s******%s' % [@order.cardNumber[0..5], @order.cardNumber[12, 15]]
    credit_card.Holder "Teste Holder"
    credit_card.ExpirationDate "12/2021"
    credit_card.SaveCard false
    credit_card.Brand "Visa"
  end
  payment.ProofOfSale "674532"
  payment.AcquirerTransactionId "0305023644309"
  payment.AuthorizationCode "123456"
  payment.PaymentId "24bc8366-fc31-4d6c-8555-17049a836a07"
  payment.Type "CreditCard"
  payment.Amount (@order.amount.to_f * 100)
  payment.Installments 1
  payment.ReceivedDate "2015-04-25 08:34:04"
  payment.Currency "BRL"
  payment.Country "BRA"
  payment.Provider "Simulado"
  payment.ReasonCode (@order.authorized? ? 0 : 7)
  payment.ReasonMessage (@order.authorized? ? "Successful" : "Denied")
  payment.Status (@order.authorized? ? 1 : 3)
  payment.ProviderReturnCode (@order.authorized? ? "4" : "2")
  payment.ProviderReturnMessage (@order.authorized? ? "Operation Successful" : "Not Authorized")
  payment.Links []
end

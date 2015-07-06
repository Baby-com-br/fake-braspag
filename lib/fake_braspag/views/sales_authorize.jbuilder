json.MerchantOrderId @sale.id
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
    credit_card.CardNumber @sale.card_number
    credit_card.Holder "Teste Holder"
    credit_card.ExpirationDate "12/2021"
    credit_card.SaveCard @sale.save_card
    credit_card.Brand "Visa"
    credit_card.CardToken @sale.card_token if @sale.save_card
  end
  payment.ProofOfSale "674532"
  payment.AcquirerTransactionId "0305023644309"
  payment.AuthorizationCode "123456"
  payment.PaymentId "24bc8366-fc31-4d6c-8555-17049a836a07"
  payment.Type "CreditCard"
  payment.Amount @sale.amount
  payment.Installments 1
  payment.ReceivedDate "2015-04-25 08:34:04"
  payment.Currency "BRL"
  payment.Country "BRA"
  payment.Provider "Simulado"
  payment.ReasonCode @sale.reason_code
  payment.ReasonMessage @sale.reason_message
  payment.Status @sale.status
  payment.ProviderReturnCode @sale.provider_return_code
  payment.ProviderReturnMessage @sale.provider_return_message
  payment.Links []
end

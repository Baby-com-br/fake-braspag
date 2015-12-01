json.MerchantOrderId @sale.id
json.Customer do |customer|
  customer.Name "Comprador Teste"
end
json.Payment do |payment|
  payment.Instructions "Aceitar somente ate a data de vencimento, apos essa data juros de 1 por cento dia."
  payment.ExpirationDate Date.tomorrow.strftime('%Y-%m-%d')
  payment.Url "https =>//apisandbox.braspag.com.br/post/pagador/reenvia.asp/a5f3181d-c2e2-4df9-a5b4-d8f6edf6bd51"
  payment.BoletoNumber "123-2"
  payment.BarCodeNumber "00096629900000157000494250000000012300656560"
  payment.DigitableLine "00090.49420 50000.000013 23006.565602 6 62990000015700"
  payment.Assignor "Empresa Teste"
  payment.Address "Rua Teste"
  payment.Identification "11884926754"
  payment.PaymentId @sale.payment_id
  payment.Type "Boleto"
  payment.Amount @sale.amount
  payment.ReceivedDate "2015-04-25 08:34:04"
  payment.Currency "BRL"
  payment.Country "BRA"
  payment.Provider "Simulado"
  payment.ReasonCode @sale.reason_code
  payment.ReasonMessage @sale.reason_message
  payment.Status @sale.status
  payment.Links []
end

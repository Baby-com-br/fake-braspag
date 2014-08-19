# Fake Braspag

Fake webservice for the Braspag payment gateway.

It can be used to:

* Execute performance tests.
* Execute END-2-END tests.
* Test failed operations that Braspag doesn't provide on its sandbox environment.

## Supported operations

The current operations are supported:

* Order authorization
* Order capture
* Order partial capture
* Credit card save
* JustClick shop

### Order authorization

**Endpoint:** `POST /webservices/pagador/Pagador.asmx/Authorize`

**Valid parameters:**

```
merchantId
orderId
customerName
amount
paymentMethod
holder
cardNumber
expiration
securityCode
numberPayments
typePayment
```

**Example Response:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>18.36</amount>
  <authorisationNumber>505369</authorisationNumber>
  <message>Operation Successful</message>
  <returnCode>4</returnCode>
  <status>1</status>
  <transactionId>0728043853882</transactionId>
</PagadorReturn>
```

**Variants:**

1 - Use `cardNumber` with the value `4242424242424242` to get a failure response.

Example of the failure response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>18.36</amount>
  <message>Not Authorized</message>
  <returnCode>2</returnCode>
  <status>2</status>
  <transactionId>0728043853882</transactionId>
</PagadorReturn>
```

### Order capture

**Endpoint:** `POST /webservices/pagador/Pagador.asmx/Capture`

**Valid parameters:**

```
merchantId
orderId
```

**Example Response:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>10.20</amount>
  <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:257575054    VALOR:        10.20@ESTAB:040187624 FAKE BRASPAG          @24.07.14-16:27:33 TERM:RO128278/528374@AUTORIZACAO EMISSOR: 642980           @CODIGO PRE-AUTORIZACAO: 52978         @CARTAO: xxxxxxxxxxxx1111              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
  <returnCode>0</returnCode>
  <status>0</status>
  <transactionId>257575054</transactionId>
</PagadorReturn>
```

**Variants:**

1 - Returns a not found response when the order id is not authorized.

Example of the not found response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount xsi:nil="true"/>
  <message>Transaction not available for capture. Please check the status of this transaction.</message>
  <returnCode>1111</returnCode>
  <status xsi:nil="true"/>
</PagadorReturn>
```

2 - Returns a failure response when the feature is disabled.

Example of the failure response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>10.20</amount>
  <message>Capture denied</message>
  <returnCode>2</returnCode>
  <status>2</status>
  <transactionId>257575054</transactionId>
</PagadorReturn>
```

### Order partial capture

**Endpoint:** `POST /webservices/pagador/Pagador.asmx/CapturePartial`

**Valid parameters:**

```
merchantId
orderId
captureAmount
```

**Example Response:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>12.34</amount>
  <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:247524362    VALOR:       12,34@                NUM. PARCELA:      01@ESTAB:040187624 FAKE BRASPAG          @24.07.14-16:38:47 TERM:RO128278/531425@AUTORIZACAO EMISSOR: 214111           @CODIGO PRE-AUTORIZACAO: 14111         @CARTAO: xxxxxxxxxxxx1111              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
  <returnCode>0</returnCode>
  <status>0</status>
</PagadorReturn>
```

**Variants:**

1 - Returns a not found response when the order id is not authorized.

Example of the not found response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount xsi:nil="true"/>
  <message>Transaction specified was not found in the database</message>
  <returnCode>1003</returnCode>
  <status xsi:nil="true"/>
</PagadorReturn>
```

2 - Returns a failure response when the feature is disabled.

Example of the failure response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>12,34</amount>
  <message>Capture partial denied</message>
  <returnCode>2</returnCode>
  <status>2</status>
  <transactionId>257575054</transactionId>
</PagadorReturn>
```

### Protected Credit Card

**Endpoint:** `POST /FakeCreditCard/CartaoProtegido.asmx`

#### Save Credit Card

**Valid parameters:**

```
RequestId
MerchantKey
CustomerName
CardHolder
CardNumber
CardExpiration
```

**Example Request:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://www.cartaoprotegido.com.br/WebService/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Body>
    <tns:SaveCreditCard>
      <tns:saveCreditCardRequestWS>
        <tns:RequestId>bf4616ea-448a-4a15-9590-ce1163f3ad50</tns:RequestId>
        <tns:MerchantKey>84be7e7f-698a-6c74-f820-ae359c2a07c2</tns:MerchantKey>
        <tns:CustomerName>John</tns:CustomerName>
        <tns:CardHolder>John Doe</tns:CardHolder>
        <tns:CardNumber>4111111111111111</tns:CardNumber>
        <tns:CardExpiration>05/2017</tns:CardExpiration>
      </tns:saveCreditCardRequestWS>
    </tns:SaveCreditCard>
  </env:Body>
</env:Envelope>
```

**Example Response:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    < xmlns="http://www.cartaoprotegido.com.br/WebService/">
      <SaveCreditCardResult>
        <JustClickKey>370a5342-c97a-4e55-8157-95c23fe18d03</JustClickKey>
        <CorrelationId>bf4616ea-448a-4a15-9590-ce1163f3ad50</CorrelationId>
        <Success>true</Success>
      </SaveCreditCardResult>
    </SaveCreditCardResponse>
  </soap:Body>
</soap:Envelope>
```

**Variants:**

1 - Returns a failure response when the feature is disabled.

Example of the failure response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <SaveCreditCardResponse xmlns="http://www.cartaoprotegido.com.br/WebService/">
      <SaveCreditCardResult>
        <Success>false</Success>
        <CorrelationId>bf4616ea-448a-4a15-9590-ce1163f3ad50</CorrelationId>
        <ErrorReportCollection>
          <ErrorReport>
            <ErrorCode>732</ErrorCode>
            <ErrorMessage>SaveCreditCardRequestId can not be null</ErrorMessage>
          </ErrorReport>
        </ErrorReportCollection>
        <JustClickKey>00000000-0000-0000-0000-000000000000</JustClickKey>
      </SaveCreditCardResult>
    </SaveCreditCardResponse>
  </soap:Body>
</soap:Envelope>
```

#### Just Click Shop

**Valid parameters:**

```
RequestId
MerchantKey
CustomerName
OrderId
Amount
PaymentMethod
NumberInstallments
PaymentType
JustClickKey
SecurityCode
```

**Example Request:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://www.cartaoprotegido.com.br/WebService/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Body>
    <tns:JustClickShop>
      <tns:justClickShopRequestWS>
        <tns:RequestId>bf4616ea-448a-4a15-9590-ce1163f3ad50</tns:RequestId>
        <tns:MerchantKey>84be7e7f-698a-6c74-f820-ae359c2a07c2</tns:MerchantKey>
        <tns:CustomerName>John</tns:CustomerName>
        <tns:OrderId>123456</tns:OrderId>
        <tns:Amount>4567</tns:Amount>
        <tns:PaymentMethod>997</tns:PaymentMethod>
        <tns:NumberInstallments>1</tns:NumberInstallments>
        <tns:PaymentType>0</tns:PaymentType>
        <tns:JustClickKey>370a5342-c97a-4e55-8157-95c23fe18d03</tns:JustClickKey>
        <tns:SecurityCode>123</tns:SecurityCode>
      </tns:justClickShopRequestWS>
    </tns:JustClickShop>
  </env:Body>
</env:Envelope>
```

**Example Response:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <JustClickShopResponse xmlns="http://www.cartaoprotegido.com.br/WebService/">
      <JustClickShopResult>
        <Success>true</Success>
        <CorrelationId>bf4616ea-448a-4a15-9590-ce1163f3ad50</CorrelationId>
        <BraspagTransactionId>00000000-0000-0000-0000-000000000000</BraspagTransactionId>
        <AquirerTransactionId>123456789</AquirerTransactionId>
        <Amount>4567</Amount>
        <AuthorizationCode>012345</AuthorizationCode>
        <Status>0</Status>
        <ReturnCode>0</ReturnCode>
        <ReturnMessage>Autorizado com sucesso</ReturnMessage>
      </JustClickShopResult>
    </JustClickShopResponse>
  </soap:Body>
</soap:Envelope>
```

**Variants:**

1 - Returns a failure response when the feature is disabled.

Example of the failure response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <JustClickShopResponse xmlns="http://www.cartaoprotegido.com.br/WebService/">
      <JustClickShopResult>
        <Success>false</Success>
        <CorrelationId>bf4616ea-448a-4a15-9590-ce1163f3ad50</CorrelationId>
        <ErrorReportCollection>
          <ErrorReport>
            <ErrorCode>726</ErrorCode>
            <ErrorMessage>Credit card expired</ErrorMessage>
          </ErrorReport>
        </ErrorReportCollection>
        <BraspagTransactionId>00000000-0000-0000-0000-000000000000</BraspagTransactionId>
        <Amount>0</Amount>
        <Status xsi:nil="true"/>
      </JustClickShopResult>
    </JustClickShopResponse>
  </soap:Body>
</soap:Envelope>
```

## Toggles endpoint

This application has some endpoint to toggle the response of some operation like capture and partial
capture.

### Disabling features

#### `GET /capture/disable`

Changes the response of the capture operation to be a failure response.

#### `GET /capture_partial/disable`

Changes the response of the partial capture operation to be a failure response.

#### `GET /save_credit_card/disable`

Changes the response of the save credit card operation to be a failure response.

#### `GET /just_click_shop/disable`

Changes the response of the just click shop operation to be a failure response.

### Enabling features

#### `GET /capture/enable`

Changes the response of the capture operation to be a successful response.

#### `GET /capture_partial/enable`

Changes the response of the partial capture operation to be a successful response.

#### `GET /save_credit_card/enable`

Changes the response of the save credit card operation to be a successful response.

#### `GET /just_click_shop/enable`

Changes the response of the just click shop operation to be a successful response.

## Development

Check the project dependencies running `script/bootstrap`. After a successful run you are ready
to developing.

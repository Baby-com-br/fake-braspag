# Fake Braspag

Fake webservice for the Braspag payment gateway.

It can be used to:

* Execute performance tests.
* Execute END-2-END tests.
* Test failure of operations that the Braspag's sandbox doesn't provide.

## Supported operations

The current operations are supported:

* Order authorization
* Order capture
* Order partial capture

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

Use `cardNumber` with the value `4242424242424242` to get a failure response.

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
  <message>F                 REDE                 @    CONFIRMACAO DE PRE-AUTORIZACAO    @COMPR:257575054    VALOR:        10.20@ESTAB:040187624 DINDA COM BR          @24.07.14-16:27:33 TERM:RO128278/528374@AUTORIZACAO EMISSOR: 642980           @CODIGO PRE-AUTORIZACAO: 52978         @CARTAO: xxxxxxxxxxxx1111              @     RECONHECO E PAGAREI A DIVIDA     @          AQUI REPRESENTADA           @@@     ____________________________     @@</message>
  <returnCode>0</returnCode>
  <transactionId>257575054</transactionId>
</PagadorReturn>
```

**Variants:**

1. Returns a not found response when the order id is not authorized.

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

2. Returns a failure response when the feature is disabled.

Example of the failure response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
  <amount>10.20</amount>
  <message>Capture denied</message>
  <returnCode>2</returnCode>
  <transactionId>257575054</transactionId>
</PagadorReturn>
```

### Order partial capture

TODO

## Toggles endpoint

This application has some endpoint to toggle the response of some operation like capture and partial
capture.

### Disabling features

#### `GET /capture/disable`

Changes the response of the capture operation to be a failure response.

### Enabling features

#### `GET /capture/enable`

Changes the response of the capture operation to be a successful response.

## Development

Check the project dependencies running `script/bootstrap`. After a successful run you are ready
to developing.

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

TODO

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

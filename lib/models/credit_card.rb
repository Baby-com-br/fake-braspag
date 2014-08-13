module FakeBraspag
  # Public: Represents a Braspag Credit Card Save request. A valid request is
  # required to build a sucessful response.
  #
  # Examples
  #
  #   card = CreditCard.new(
  #     'RequestId'      => '{BF4616EA-448A-4A15-9590-CE1163F3AD50}'
  #     'MerchantKey'    => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}'
  #     'CustomerName'   => 'John'
  #     'CardHolder'     => 'John Doe'
  #     'CardNumber'     => '4111111111111111'
  #     'CardExpiration' => '05/2017'
  #   )
  #
  #   card.correlation_id
  #   # => "bf4616ea-448a-4a15-9590-ce1163f3ad50"
  #
  #   card.just_click_key
  #   # => "370a5342-c97a-4e55-8157-95c23fe18d03"
  class CreditCard
    # Public: Initialize a CreditCard.
    #
    # attributes - A hash containing card information such as number and expiration.
    def initialize(attributes)
      request_id = uuid(attributes['RequestId'])

      @attributes = {
        'JustClickKey' => SecureRandom.uuid,
        'CorrelationId' => request_id
      }
    end

    # Public: Random UUID key used to identify a customer-card pair uniquely.
    def just_click_key
      @attributes['JustClickKey']
    end

    # Public: A transaction UUID key, matching the request `RequestId` to the response.
    def correlation_id
      @attributes['CorrelationId']
    end

    # Public: Determine if this is a valid credit card.
    #
    # A valid credit card save request must contain a
    # `RequestId`, so a `CorrelationId` can be returned.
    def valid?
      correlation_id
    end

    private

    # Private: Normalize a UUID value.
    #
    # Wrapping characters are removed and the output is downcased.
    #
    # Examples
    #
    #   uuid('{BF4616EA-448A-4A15-9590-CE1163F3AD50}')
    #   # => 'bf4616ea-448a-4a15-9590-ce1163f3ad50'
    def uuid(value)
      value[/[\h-]+/].downcase if value
    end
  end
end

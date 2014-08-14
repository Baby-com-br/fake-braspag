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
    # UUID attributes get normalized and a CorrelationId is included.
    #
    # attributes - A hash containing card request information, such as number and expiration.
    def initialize(attributes)
      @attributes = attributes.dup

      request_id = uuid(attributes['RequestId'])
      @attributes['RequestId'] = request_id
      @attributes['CorrelationId'] = request_id
    end

    # Public: Perform a fake Save operation.
    #
    # A `JustClickKey` UUID token is generated upon saving.
    #
    # Returns truthy if the request is valid and falsy otherwise.
    def save
      if correlation_id
        @attributes['JustClickKey'] = SecureRandom.uuid
      end
    end

    private

    # Public: Retrive the card attributes using a method.
    #
    # Examples:
    #
    #   card = CreditCard.new('Success' => true, 'CustomerName' => 'John Doe')
    #   card.success # => true
    #   card.customer_name # => "John Doe"
    def method_missing(name, *args)
      camelized_name = name.to_s.camelize

      @attributes.fetch(camelized_name) { super }
    end

    # Public: Check if the attribute method exists.
    #
    # Examples:
    #
    #   card = CreditCard.new('Amount' => '4.20')
    #   card.respond_to?(:amount) # => true
    #   card.respond_to?(:inexistent_method) # => false
    def respond_to_missing?(name, include_private = false)
      camelized_name = name.to_s.camelize

      @attributes.key?(camelized_name) || super
    end

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

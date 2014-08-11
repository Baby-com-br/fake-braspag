module FakeBraspag
  # Public: Represents a Braspag Credit Card Save request. A valid request is
  # required to build a sucessful response.
  #
  # Examples
  #
  #   card = CreditCard.new(braspag_request.body_as_xml)
  #   card.correlation_id
  #   # => "bf4616ea-448a-4a15-9590-ce1163f3ad50"
  #   card.just_click_key
  #   # => "370a5342-c97a-4e55-8157-95c23fe18d03"
  class CreditCard
    # Public: Random key used to identify a customer-card pair uniquely.
    attr_reader :just_click_key

    # Public: A transaction key matching the request `RequestId` to the response.
    attr_reader :correlation_id

    # Public: Initialize a CreditCard.
    #
    # xml - XML content of a SOAP `CreditCardSave` request envelope.
    def initialize(xml)
      @correlation_id = request_id(xml)
      @just_click_key = SecureRandom.uuid
    end

    # Public: Determine if this is a valid credit card.
    #
    # A valid credit card XML request must contain a
    # `RequestId`, so a `CorrelationId` can be returned.
    #
    # Returns true when the XML is well-formed and false otherwise.
    def valid?
      @correlation_id
    end

    private

    # Internal: Retrive the `RequestId` value from a XML input.
    #
    # xml - The XML String to be searched.
    #
    # Examples
    #
    #   request_id("...<tns:RequestId>{BE54D851-9B9C-4FD2-8846-F043166D60C1}<tns:RequestId>...")
    #   # => "BE54D851-9B9C-4FD2-8846-F043166D60C1"
    #
    # Returns a UUID String or nil if there is no `RequestId` tag in the XML.
    def request_id(xml)
      id = xml[ /<tns:RequestId>\s*{?(.+?)}?\s*<\//, 1 ]
      id.downcase if id
    end
  end
end

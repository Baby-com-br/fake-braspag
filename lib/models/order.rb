require 'redis'
require 'json'
require 'active_support/core_ext/string/inflections'

# Public: Class responsible to make operations upon an order.
class Order
  # Public: Raised when there is no order with the provided id on the
  # persistence layer.
  class NotFoundError < StandardError; end

  # Public: Raised when the there is a failure on the authorization.
  class AuthorizationFailureError < StandardError; end

  # Internal: The redis key prefix used to store the orders.
  KEY_PREFIX = 'fake-braspag.order.'

  # Internal: Represent the quantity of seconds in a day.
  DAY_IN_SECONDS = 24 * 60 * 60

  # Public: Returns the connection object.
  #
  # This object can be used to make raw operation on the persistence layer.
  def self.connection
    @@connection
  end

  # Public: Set the connection object.
  def self.connection=(connection)
    @@connection = connection
  end

  # Public: Find and return an order with the provided `id`.
  #
  # Examples
  #
  #   Order.find!('12345')
  #   # => #<Order:... @attributes={"orderId"=>"12345", "amount"=>"18.36"}, @persisted=true>
  #
  #   Order.find!('non existend')
  #   # => Order::NotFoundError
  #
  # Raises `Order::NotFoundError` if no order is found with the id on the
  # persistence layer.
  def self.find!(id)
    Order.new(get_value_for(key_for(id)), persisted: true)
  end

  # Public: Same as `.find!` but returns `nil` if no order is found with the given id
  # on the persistence layer.
  def self.find(id)
    find!(id)
  rescue NotFoundError
    nil
  end

  # Public: Create an order with the provided `parameters`.
  #
  # Examples
  #
  #   Order.create('orderId' => '12345', 'amount' => '18.36')
  #   # => #<Order:... @attributes={"orderId"=>"12345", "amount"=>"18.36"}, @persisted=true>
  #
  # Returns a `Order` object or false if already exist an order with the same id.
  def self.create(parameters)
    order = new(parameters)
    return_value = order.save

    order if return_value
  end

  # Public: Returns the number of orders on the persistence layer.
  def self.count
    connection.keys(KEY_PREFIX + '*').size
  end

  # Internal: Returns the full key to be used on the persistence layer.
  def self.key_for(id)
    KEY_PREFIX + id.to_s
  end

  # Internal: Get the value of the order attributes from the persistence layer.
  #
  # Returns a `Hash` with the attributes.
  # Raises `Order::NotFoundError` if the key is not persisted.
  def self.get_value_for(key)
    value = connection.get(key)

    if value
      JSON.load(value)
    else
      raise NotFoundError
    end
  end

  # Public: Initialize a Order.
  #
  # attributes - a Hash with the order attributes.
  def initialize(attributes, options = {})
    attributes['amount'] = normalize_amount(attributes['amount'])

    @attributes = attributes
    @persisted = options.fetch(:persisted, false)
  end

  # Public: Saves the object on the persistence layer.
  #
  # Returns true if the object could be saved, false otherwise.
  def save
    options = @persisted ? { xx: true, ex: 30 * DAY_IN_SECONDS } : { nx: true, ex: 30 * DAY_IN_SECONDS }

    success = connection.set(self.class.key_for(id), to_json, options)

    @persisted = true if success

    success
  end

  # Public: Reload the attributes information for the persistence layer.
  #
  # Raises `Order::NotFoundError` if no order is found with the id on the
  # persistence layer.
  def reload
    @attributes = self.class.get_value_for(self.class.key_for(id))
    @persisted = true
  end

  # Public: Marks the order as authorized.
  #
  # Raises `Order::AuthorizationFailureError` if the there is a failure on
  # the authorization.
  def authorize!
    if can_be_authorized?
      @attributes['status'] = 'authorized'
      save
    else
      raise AuthorizationFailureError
    end
  end

  # Public: Simulates an order capture. Either full or partial.
  #
  # amount - The amount to be charged. Making it a partial capture (default: nil).
  #
  # Examples
  #
  #   order.capture('12,34')
  #   # => true
  #
  # Returns true if the capture was successful and false otherwise.
  def capture!(amount = nil)
    @attributes['status'] = 'captured'
    @attributes['capturedAmount'] = normalize_amount(amount) if amount

    save
  end

  # Public: Simulates an order boleto payment.
  #
  # Examples
  #
  #   order.pay_boleto!
  #   # => true
  #
  # Returns true if the payment was successful and false otherwise.
  def pay_boleto!(amount = nil)
    if amount
      normalized_amount = normalize_amount(amount)
      @attributes['boleto_status'] = 'boleto_paid' if normalized_amount.to_i >= self.amount.to_i
      @attributes['capturedAmount'] = normalized_amount
    else
      @attributes['boleto_status'] = 'boleto_paid'
      @attributes['capturedAmount'] = self.amount
    end

    save
  end

  # Public: Checks if the order is authorized.
  def authorized?
    @attributes['status'] == 'authorized'
  end

  # Public: Checks if the order is captured.
  def captured?
    @attributes['status'] == 'captured'
  end

  # Public: Checks if the order is paid with boleto.
  def boleto_paid?
    @attributes['boleto_status'] == 'boleto_paid'
  end

  # Public: Checks if the order payment method is boleto
  def boleto?
    @attributes['paymentMethod'] == 'Boleto'
  end

  # Public: Returns the order id.
  def id
    @attributes['orderId']
  end

  # Public: Returns the card number used on the order.
  #
  # Returns the masked value with only the last four digits present.
  def card_number
    mask_card_number(@attributes['cardNumber'])
  end

  # Internal: Serializes the attributes to JSON.
  def to_json
    @attributes.to_json
  end

  def connection
    self.class.connection
  end

  private

  # Internal: Normalize the amount value to always use `'.'` as decimal
  # separator.
  def normalize_amount(amount)
    amount.gsub(',', '.') if amount
  end

  # Internal: Add a mask to `card_number` to only show the last 4 digits.
  def mask_card_number(card_number)
    "xxxxxxxxxxxx%s" % card_number[-4..-1] if card_number
  end

  # Internal: Checks if the order can be authorized.
  def can_be_authorized?
    @attributes['cardNumber'] != '4242424242424242'
  end

  # Public: Retrive the order attributes using a method.
  #
  # Examples
  #
  #   order = Order.new('amount' => '4.20', 'customerName' => 'Rafael França')
  #   order.amount # => "4.20"
  #   order.customer_name # => "Rafael França"
  def method_missing(name, *args)
    camelized_name = name.to_s.camelize(:lower)

    @attributes.fetch(camelized_name) { super }
  end

  # Public: Checks if the attribute method exists.
  #
  # Examples
  #
  #   order = Order.new('amount' => '4.20')
  #   order.respond_to?(:amount) # => true
  #   order.respond_to?(:inexistent_method) # => false
  def respond_to_missing?(name, include_private = false)
    camelized_name = name.to_s.camelize(:lower)

    @attributes.key?(camelized_name) || super
  end
end

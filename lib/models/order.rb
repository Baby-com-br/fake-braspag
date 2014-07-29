require 'redis'
require 'json'

class Order
  class NotFoundError < StandardError; end

  KEY_PREFIX = 'fake-braspag.order.'

  @@connection = Redis.new

  def self.connection
    @@connection
  end

  def self.find(id)
    Order.new(JSON.load(connection.get(key_for(id))), persisted: true)
  end

  def self.create(parameters)
    order = new(parameters)
    return_value = order.save

    order if return_value
  end

  def self.count
    connection.keys(KEY_PREFIX + '*').size
  end

  def self.key_for(id)
    KEY_PREFIX + id.to_s
  end

  def initialize(attributes, persisted: false)
    attributes['amount'] = normalize_amount(attributes['amount'])
    attributes['cardNumber'] = mask_card_number(attributes['cardNumber'])

    @attributes = attributes
    @persisted = persisted
  end

  def save
    options = @persisted ? { xx: true } : { nx: true }

    success = connection.set(self.class.key_for(self['orderId']), to_json, options)

    @persisted = true if success

    success
  end

  def reload
    value = connection.get(self.class.key_for(self['orderId']))

    if value
      @attributes = JSON.load(value)
      @persisted = true
    else
      raise NotFoundError
    end
  end

  def captured?
    @attributes['status'] == 'captured'
  end

  def [](attribute)
    @attributes[attribute]
  end

  def to_json
    @attributes.to_json
  end

  def connection
    self.class.connection
  end

  private

  def normalize_amount(amount)
    amount.gsub(',', '.') if amount
  end

  def mask_card_number(card_number)
    "************%s" % card_number[-4..-1] if card_number
  end
end

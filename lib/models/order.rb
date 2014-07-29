require 'redis'
require 'json'

class Order
  KEY_PREFIX = 'fake-braspag.order.'

  @@connection = Redis.new

  def self.connection
    @@connection
  end

  def self.find(id)
    Order.new(JSON.load(connection.get(key_for(id))))
  end

  def self.create(parameters)
    order = new(parameters)
    return_value = connection.set(key_for(parameters['orderId']), order.to_json, nx: true)

    order if return_value
  end

  def self.count
    connection.keys(KEY_PREFIX + '*').size
  end

  def self.key_for(id)
    KEY_PREFIX + id.to_s
  end

  def initialize(attributes)
    attributes['amount'] = normalize_amount(attributes['amount'])
    attributes['cardNumber'] = mask_card_number(attributes['cardNumber'])

    @attributes = attributes
  end

  def save
    self.class.connection.set(self.class.key_for(self['orderId']), to_json)
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

  private

  def normalize_amount(amount)
    amount.gsub(',', '.')
  end

  def mask_card_number(card_number)
    "************%s" % card_number[-4..-1]
  end
end

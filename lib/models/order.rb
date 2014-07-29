require 'redis'
require 'json'

class Order
  KEY_PREFIX = 'fake-braspag.order.'

  @@connection = Redis.new

  def self.connection
    @@connection
  end

  def self.find(id)
    JSON.load(connection.get(key_for(id)))
  end

  def self.create(parameters)
    parameters['amount'] = normalize_amount(parameters['amount'])
    parameters['cardNumber'] = mask_card_number(parameters['cardNumber'])

    return_value = connection.set(key_for(parameters['orderId']), parameters.to_json, nx: true)

    parameters if return_value
  end

  def self.count
    connection.keys(KEY_PREFIX + '*').size
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def captured?
    @attributes['status'] == 'captured'
  end

  def self.normalize_amount(amount)
    amount.gsub(',', '.')
  end
  private_class_method :normalize_amount

  def self.mask_card_number(card_number)
    "************%s" % card_number[-4..-1]
  end
  private_class_method :mask_card_number

  def self.key_for(id)
    KEY_PREFIX + id.to_s
  end
  private_class_method :key_for
end

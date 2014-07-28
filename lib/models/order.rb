require 'redis'
require 'json'

class Order
  @@connection = Redis.new

  def self.find(id)
    JSON.load(@@connection.get(id))
  end

  def self.create(parameters)
    parameters['amount'] = normalize_amount(parameters['amount'])
    @@connection.set parameters['orderId'], parameters.to_json
    parameters
  end

  def self.normalize_amount(amount)
    amount.gsub(',', '.')
  end
  private_class_method :normalize_amount
end

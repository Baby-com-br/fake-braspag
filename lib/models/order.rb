require 'redis'
require 'json'

class Order
  @@connection = Redis.new

  def self.find(id)
    JSON.load(@@connection.get(id))
  end

  def self.create(parameters)
    @@connection.set parameters['orderId'], parameters.to_json
    parameters
  end
end

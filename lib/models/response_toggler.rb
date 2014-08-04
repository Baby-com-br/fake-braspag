class ResponseToggler
  # Internal: The redis key prefix used to store the orders.
  KEY_PREFIX = 'fake-braspag.disabled_response.'

  @@connection = Redis.new

  # Public: Returns the connection object.
  #
  # This object can be used to make raw operation on the persistence layer.
  def self.connection
    @@connection
  end

  # Public: Disable the response for the given `namespace`.
  def self.disable(namespace)
    connection.set(KEY_PREFIX + namespace, true, ex: 60 * 60)
  end
end

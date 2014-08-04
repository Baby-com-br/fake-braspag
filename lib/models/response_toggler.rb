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
    connection.set(key_for(namespace), true, ex: 60 * 60)
  end

  # Public: Enable the response for the given `namespace`.
  def self.enable(namespace)
    connection.del(key_for(namespace))
  end

  # Public: Check if the response is enabled got the given `namespace`.
  def self.enabled?(namespace)
    !connection.exists(key_for(namespace))
  end

  # Internal: Returns the full key to be used on the persistence layer.
  def self.key_for(namespace)
    KEY_PREFIX + namespace.to_s
  end
  private_class_method :key_for
end

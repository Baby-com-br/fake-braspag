# Public: Class responsible to determine if a response will be successful.
class ResponseToggler
  # Internal: The redis key prefix used to store the orders.
  KEY_PREFIX = 'fake-braspag.disabled_response.'

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

  # Public: Disable the response for the given `feature`.
  def self.disable(feature)
    connection.set(key_for(feature), true, ex: 60 * 60)
  end

  # Public: Enable the response for the given `feature`.
  def self.enable(feature)
    connection.del(key_for(feature))
  end

  # Public: Check if the response is enabled for the given `feature`.
  def self.enabled?(feature)
    !connection.exists(key_for(feature))
  end

  # Internal: Returns the full key to be used on the persistence layer.
  def self.key_for(feature)
    KEY_PREFIX + feature.to_s
  end
  private_class_method :key_for
end

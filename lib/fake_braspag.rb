require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra/base'
require 'builder'
require 'active_support'
require 'active_support/core_ext/object/blank'

$: << File.dirname(__FILE__)

require 'models/order'
require 'models/response_toggler'
require 'fake_braspag/webservices'
require 'fake_braspag/toggler'

connection = Redis.new

Order.connection = connection
ResponseToggler.connection = connection

module FakeBraspag
  @env = nil

  # Public: The base exception class raised when errors are encountered.
  class Error < StandardError; end

  # Public: Setup the application.
  #
  # settings - Hash of app settings. Typically ENV but any object that responds
  #            to #[], #[]= and #each is valid. See required_settings for
  #            required keys. The RACK_ENV key is always required.
  #
  # Raises an Error when required settings are missing.
  # Returns nothing.
  def self.setup(settings)
    @env = settings["RACK_ENV"]

    if @env.blank?
      raise Error, "RACK_ENV is required"
    end

    required_settings.each do |setting|
      next if settings[setting].present?

      if @env == "production"
        raise Error, "#{setting} setting is required"
      end
    end

    FakeBraspag::Toggler.set(
      username: settings['FAKE_BRASPAG_TOGGLER_USERNAME'],
      password: settings['FAKE_BRASPAG_TOGGLER_PASSWORD']
    )
  end

  # Internal: The application environment.
  def self.env
    @env
  end

  # Internal: List of settings required in production.
  #
  # Returns an Array of Strings.
  def self.required_settings
    %w[FAKE_BRASPAG_TOGGLER_USERNAME FAKE_BRASPAG_TOGGLER_PASSWORD]
  end

  # Public: The Fake Braspag Rack application, assembled from two apps.
  #
  # Returns a memoized Rack application.
  def self.app
    @app ||= Rack::Builder.app {
      map '/webservices/pagador/Pagador.asmx' do
        run FakeBraspag::Webservices
      end

      map '/' do
        if FakeBraspag.env == 'production'
          use Rack::Auth::Basic do |username, password|
            username == FakeBraspag::Toggler.username &&
              password == FakeBraspag::Toggler.password
          end
        end

        run FakeBraspag::Toggler
      end
    }
  end
end

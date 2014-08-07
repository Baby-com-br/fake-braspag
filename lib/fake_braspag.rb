require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra/base'
require 'builder'

$: << File.dirname(__FILE__)

require 'models/order'
require 'models/response_toggler'
require 'fake_braspag/webservices'
require 'fake_braspag/toggler'

connection = Redis.new

Order.connection = connection
ResponseToggler.connection = connection

module FakeBraspag
  # Public: The Fake Braspag Rack application, assembled from two apps.
  #
  # Returns a memoized Rack application.
  def self.app
    @app ||= Rack::Builder.app {
      map '/webservices/pagador/Pagador.asmx' do
        run FakeBraspag::Webservices
      end

      map '/' do
        run FakeBraspag::Toggler
      end
    }
  end
end

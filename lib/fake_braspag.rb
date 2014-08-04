require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra/base'
require 'builder'

$: << File.dirname(__FILE__)

require 'models/order'
require 'models/response_toggler'
require 'fake_braspag/webservices'

connection = Redis.new

Order.connection = connection
ResponseToggler.connection = connection

module FakeBraspag
  class Application < Sinatra::Base
    get '/:feature/disable' do
      if ResponseToggler.enabled?(params[:feature])
        ResponseToggler.disable(params[:feature])

        halt 200
      else
        halt 304
      end
    end

    get '/:feature/enable' do
      if !ResponseToggler.enabled?(params[:feature])
        ResponseToggler.enable(params[:feature])

        halt 200
      else
        halt 304
      end
    end
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
        run FakeBraspag::Application
      end
    }
  end
end

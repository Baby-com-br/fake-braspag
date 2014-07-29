require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra/base'
require 'builder'

$: << File.dirname(__FILE__)

require 'models/order'

module FakeBraspag
  class Application < Sinatra::Base
    post '/webservices/pagador/Pagador.asmx/Authorize' do
      order = Order.create params
      builder :authorize_success, {}, { order: order }
    end

    post '/webservices/pagador/Pagador.asmx/Capture' do
      order = Order.find!(params['orderId'])

      if order
        order.capture!
        builder :capture_success, {}, { order: order }
      else
        builder :capture_not_available
      end
    end
  end
end

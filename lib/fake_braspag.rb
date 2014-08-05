require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra/base'
require 'builder'

$: << File.dirname(__FILE__)

require 'models/order'
require 'models/response_toggler'

connection = Redis.new

Order.connection = connection
ResponseToggler.connection = connection

module FakeBraspag
  class Application < Sinatra::Base
    post '/webservices/pagador/Pagador.asmx/Authorize' do
      order = Order.new params

      begin
        order.authorize!

        builder :authorize_success, {}, { order: order }
      rescue Order::AuthorizationFailureError
        builder :authorize_failure, {}, { order: order }
      end
    end

    post '/webservices/pagador/Pagador.asmx/Capture' do
      order = Order.find(params['orderId'])

      if order
        if ResponseToggler.enabled?('capture')
          order.capture!
          builder :capture_success, {}, { order: order }
        else
          builder :capture_failure, {}, { order: order }
        end
      else
        builder :capture_not_available
      end
    end

    post '/webservices/pagador/Pagador.asmx/CapturePartial' do
      order = Order.find(params['orderId'])
      amount = params['captureAmount']

      if order
        if ResponseToggler.enabled?('capture_partial')
          order.capture!(amount)
          builder :capture_partial_success, {}, { order: order }
        else
          builder :capture_partial_failure, {}, { order: order }
        end
      else
        builder :capture_partial_not_found
      end
    end

    get '/capture/disable' do
      if ResponseToggler.enabled?('capture')
        ResponseToggler.disable('capture')

        halt 200
      else
        halt 304
      end
    end

    get '/capture/enable' do
      if !ResponseToggler.enabled?('capture')
        ResponseToggler.enable('capture')

        halt 200
      else
        halt 304
      end
    end
  end
end

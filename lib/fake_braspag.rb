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
      Order.create params
      builder :authorize_success, params
    end

    post '/webservices/pagador/Pagador.asmx/Capture' do
      builder :capture_success
    end
  end
end

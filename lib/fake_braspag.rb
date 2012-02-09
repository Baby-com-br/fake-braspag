require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.require 

$: << File.dirname(__FILE__)

require "order"
require "credit_card"
require "bill"
require "settings"

module FakeBraspag
  module PaymentType
    CREDIT_CARD = 1
    BILL        = 2
    TEF         = 3
  end
    
  class App < Sinatra::Base
    configure do
      set :root, File.dirname(__FILE__)
      set :views, settings.root + '/templates'
      set :show_expections, false
      register Order
      register CreditCard
      register Bill
    end
  end
end

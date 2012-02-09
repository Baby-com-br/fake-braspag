require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.require 

$: << File.dirname(__FILE__)

require "order"
require "credit_card"
require "bill"
require "eft"
require "settings"

module FakeBraspag
  module PaymentType
    CREDIT_CARD = 1
    BILL        = 2
    EFT         = 3
  end
    
  class App < Sinatra::Base
    private
    def change_bill_status(status)
      Order.change_status params[:order_id], status
    end

    def pay_bill
      change_bill_status Order::Status::PAID 
    end

    def cancel_bill
      change_bill_status Order::Status::CANCELLED
    end
    
    def crypt_value
      Braspag::Crypto::JarWebservice.encrypt({
        :VENDAID => params[:order_id]
      })
    end
    
    configure do
      set :root, File.dirname(__FILE__)
      set :views, settings.root + '/templates'
      set :show_expections, false
      register Order
      register CreditCard
      register Bill
      register Eft
    end
  end
end

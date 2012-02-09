require "bundler/setup"

Bundler.require 

$: << File.dirname(__FILE__)

require "order"
require "credit_card"
require "dados_pedido"
require "bill"

module FakeBraspag
  class App < Sinatra::Base
    configure do
      set :root, File.dirname(__FILE__)
      set :views, settings.root + '/templates'
      set :show_expections, false
      register CreditCard
      register DadosPedido
      register Bill
    end
  end
end

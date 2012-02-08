require "bundler/setup"

Bundler.require 

$: << File.dirname(__FILE__)

require "credit_card"
require "dados_pedido"

module FakeBraspag
  class App < Sinatra::Base
    configure do
      set :show_expections, false
      register CreditCard
      register DadosPedido
    end
  end
end

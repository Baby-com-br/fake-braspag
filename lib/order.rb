require "redis"
require "yajl"

module FakeBraspag
  DADOS_PEDIDO_URI = "/pagador/webservice/pedido.asmx/GetDadosPedido"

  class App < Sinatra::Base
    private
    def order(order_id)
      Order.order order_id
    end
    
    def order_amount
      order(params[:numeroPedido]).nil? ? "" : order(params[:numeroPedido])[:amount]
    end
    
    def order_status
      return nil if order(params[:numeroPedido]).nil?
      order(params[:numeroPedido])[:status]
    end
  end
  
  module Order
    module Status
      PENDING   = "1"
      PAID      = "3"
      CANCELLED = "4"
    end
    
    def self.redis
      @redis ||= Redis.new
    end
    
    def self.order(order_id)
      Yajl::Parser.parse(redis.get("fake_braspag_#{order_id}")).inject({}) { |hash, pair| 
        hash[pair.first.to_sym] = pair.last
        hash
      }
    end
    
    def self.set_on_redis(order_id, _order)
      redis.set "fake_braspag_#{order_id}", _order.to_json
    end
    
    def self.clear_orders
      keys = redis.keys("fake_braspag*")
      redis.del *keys if keys.size > 0
    end
    
    def self.save_order(params)
      params[:status] ||= Status::PENDING
      order_to_save = {
        :type        => params[:type],
        :card_number => params[:card_number],
        :amount      => params[:amount].gsub(",", "."),
        :status      => params[:status] 
      }

      set_on_redis params[:order_id], order_to_save
      send_ipn(params[:order_id]) if should_send_ipn?(params[:status])
      order_to_save
    end
    
    def self.should_send_ipn?(status)
      [Status::PAID, Status::CANCELLED].include?(status)
    end
    
    def self.change_status(order_id, status)
      order_to_update = order(order_id)
      order_to_update[:status] = status 
      send_ipn(order_id) if should_send_ipn?(status)
      set_on_redis order_id, order_to_update
    end
    
    def self.send_ipn(order_id)
      request = ::HTTPI::Request.new(Settings.ipn_post)
      request.body = {
        :crypt => Braspag::Crypto::JarWebservice.encrypt({
          :NumPedido => order_id
        })
      }
      ::HTTPI.post(request)      
    end
    
    def self.registered(app)
      app.post DADOS_PEDIDO_URI do
        <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns="http://www.pagador.com.br/">
            <CodigoAutorizacao>885796</CodigoAutorizacao>
            <CodigoPagamento>18</CodigoPagamento>
            <FormaPagamento>American Express 2P</FormaPagamento>
            <NumeroParcelas>1</NumeroParcelas>
            <Status>#{order_status}</Status>
            <Valor>#{order_amount}</Valor>
            <DataPagamento>7/8/2011 1:19:38 PM</DataPagamento>
            <DataPedido>7/8/2011 1:06:06 PM</DataPedido>
            <TransId>398591</TransId>
            <BraspagTid>5a1d4463-1d11-4571-a877-763aba0ef7ff</BraspagTid>
          </DadosPedido>
        EOXML
      end
    end
  end
end

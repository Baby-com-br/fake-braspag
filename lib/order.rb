module FakeBraspag
  DADOS_PEDIDO_URI = "/pagador/webservice/pedido.asmx/GetDadosPedido"

  class App < Sinatra::Base
    private
    def order_amount
      Order.orders[params[:numeroPedido]].nil? ? "" : Order.orders[params[:numeroPedido]][:amount]
    end
    
    def order_status
      return nil if Order.orders[params[:numeroPedido]].nil?
      Order.orders[params[:numeroPedido]][:status]
    end
  end
  
  module Order
    module Status
      PENDING   = "1"
      PAID      = "3"
      CANCELLED = "4"
    end

    def self.orders
      @orders ||= {}
    end
    
    def self.clear_orders
      @orders.clear 
    end
    
    def self.save_order(params)
      orders[params[:order_id]] = {
        :type        => params[:type],
        :card_number => params[:card_number],
        :amount      => params[:amount].gsub(",", "."),
        :ipn_sent    => false
      }
      
      self.change_status(params[:order_id], params[:status])
      orders[params[:order_id]]
    end
    
    def self.change_status(order_id, status = nil)
      orders[order_id][:status] = status || Status::PENDING
      send_ipn(order_id) if [Status::PAID, Status::CANCELLED].include?(status) && !orders[order_id][:ipn_sent]
    end
    
    def self.send_ipn(order_id)
      orders[order_id][:ipn_sent] = true 
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

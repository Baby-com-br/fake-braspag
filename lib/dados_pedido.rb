module FakeBraspag
  DADOS_PEDIDO_URI = "/pagador/webservice/pedido.asmx/GetDadosPedido"

  class App < Sinatra::Base
    private
    def dados_pedido_status
      return nil if Order.orders[params[:numeroPedido]].nil?
      Order.orders[params[:numeroPedido]][:status]
    end
  end

  module DadosPedido
    module Status
      PENDING   = "1"
      PAID      = "3"
      CANCELLED = "4"
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
            <Status>#{dados_pedido_status}</Status>
            <Valor>#{amount_for_get_dados_pedido}</Valor>
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

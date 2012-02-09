module FakeBraspag
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
  end
end

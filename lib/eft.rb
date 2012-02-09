# encoding: utf-8
module FakeBraspag
  EFT_URL = "/pagador/passthru.asp"

  class App < Sinatra::Base
    private

    def generate_eft
      params[:status]   = Order::Status::PENDING
      params[:type]     = PaymentType::EFT
      Order.save_order params
    end
  end

  module Eft
    def self.registered(app)
      app.post EFT_URL do
        if params[:action].blank?
          generate_eft
          erb :choice
        else
          params[:action] == "pay" ? pay_bill : cancel_bill
          erb :return
        end
      end
    end
  end
end


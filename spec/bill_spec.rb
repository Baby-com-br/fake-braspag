# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }
  let(:body) { Nokogiri::XML last_response.body }
  let(:body_html) { Nokogiri::HTML last_response.body }

  context "CreateBoleto method" do
    before { do_post payment_method }

    def do_post(payment_method)
      post FakeBraspag::GENERATE_BILL_URL, :orderId => order_id, :amount => amount_for_post, :paymentMethod => payment_method
    end

    def returned_status
      body.css("status").text
    end

    def returned_code
      body.css("returnCode").text
    end

    def returned_url
      body.css("url").text
    end

    def returned_amount
      body.css("amount").text
    end

    context "with success" do
      let(:payment_method) { FakeBraspag::Bill::PAYMENT_METHOD_OK }     

      it "returns an XML with the sent amount" do
        returned_amount.should == amount
      end

      it "returns an XML with the success return code" do
        returned_code.should == FakeBraspag::Bill::ReturnCode::SUCCESS
      end
      
      it "returns an XML with an sample url" do
        returned_url.should == "http://example.org/boleto?Id_Transacao=#{order_id}"
      end

      it "returns an XML with the success status" do
        returned_status.should == FakeBraspag::Bill::Status::SUCCESS
      end

      it "adds the order to the list of received order" do
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::BILL,
            :status      => FakeBraspag::Order::Status::PENDING,
            :amount      => amount,
            :card_number => nil
          }
        }
      end
    end

    context "with error" do
      let(:payment_method) { FakeBraspag::Bill::PAYMENT_METHOD_ERROR }     
      
      it "returns an XML with an empty amount" do
        returned_amount.should == ""
      end

      it "returns an XML with an empty status" do
        returned_status.should == ""
      end

      it "returns an XML with an empty url" do
        returned_url.should == ""
      end

      it "returns an XML with the error return code" do
        returned_code.should == FakeBraspag::Bill::ReturnCode::ERROR
      end

      it "adds the order to the list of received order" do
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::BILL,
            :status      => FakeBraspag::Order::Status::CANCELLED,
            :amount      => amount,
            :card_number => nil
          }
        }
      end
    end
  end

  context "Boleto method" do
    def do_post(order_id, action)
      get FakeBraspag::BILL_URL, :order_id => order_id, :action => action
    end

    def do_get(order_id)
      get FakeBraspag::BILL_URL, :Id_Transacao => order_id
    end
    
    context "view bill" do
      before { do_get order_id }
      
      def returned_button(button)
        body_html.css(button)[0]
      end
      
      it "return a form" do
        body_html.css("form")[0]["action"].should == "?order_id=#{order_id}"
      end
      
      it "return a pay button" do
        returned_button("button.pay")["value"].should == "pay"
        returned_button("button.pay").text.should == "Pagar"
      end
      
      it "return a cancel button" do
        returned_button("button.cancel")["value"].should == "cancel"
        returned_button("button.cancel").text.should == "Cancelar"
      end
    end
    
    context "pay Bill" do
      before { do_post(order_id, "pay") }
    end
    
    context "cancel Bill" do
      before { do_post(order_id, "cancel") }
    end
  end

  context "paying a bill" do
    def do_post
      post FakeBraspag::BILL_URL, :order_id => order_id, :action => "pay"
    end

    before { 
      post FakeBraspag::GENERATE_BILL_URL, :orderId => order_id, :amount => amount_for_post, :paymentMethod => FakeBraspag::Bill::PAYMENT_METHOD_OK 
    }

    it "changes the order status to paid" do
      do_post
      FakeBraspag::Order.orders[order_id][:status].should == FakeBraspag::Order::Status::PAID
    end
  end

  context "cancelling a bill" do
    def do_post
      post FakeBraspag::BILL_URL, :order_id => order_id, :action => "cancel"
    end

    before { 
      post FakeBraspag::GENERATE_BILL_URL, :orderId => order_id, :amount => amount_for_post, :paymentMethod => FakeBraspag::Bill::PAYMENT_METHOD_OK 
    }

    it "changes the order status to cancelled" do
      do_post
      FakeBraspag::Order.orders[order_id][:status].should == FakeBraspag::Order::Status::CANCELLED
    end    
  end
end

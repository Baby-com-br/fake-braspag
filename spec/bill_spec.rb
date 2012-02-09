# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  before  do
    ::HTTPI.stub(:post)
  end
  
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }
  let(:body) { Nokogiri::XML last_response.body }
  let(:body_html) { Nokogiri::HTML last_response.body }

  context "CreateBoleto method" do
    before do
      Braspag::Crypto::JarWebservice.stub(:encrypt)
    end

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
            :card_number => nil,
            :amount      => amount,
            :ipn_sent    => false,
            :status      => FakeBraspag::Order::Status::PENDING
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
            :card_number => nil,
            :amount      => amount,
            :ipn_sent    => true,
            :status      => FakeBraspag::Order::Status::CANCELLED
          }
        }
      end
    end
  end

  context "Boleto method" do
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
  end

  context "paying a bill" do
    before { 
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :numpedido => order_id
                                    })
                                    .and_return("CRYPTO")
      
      post FakeBraspag::GENERATE_BILL_URL, :orderId => order_id, :amount => amount_for_post, :paymentMethod => FakeBraspag::Bill::PAYMENT_METHOD_OK 
    }
    
    def do_post
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :VENDAID => order_id
                                    })
                                    .and_return("CRYPTO")
      
      post FakeBraspag::BILL_URL, :order_id => order_id, :action => "pay"
    end
    
    def returned_button(button)
      body_html.css(button)[0]
    end

    it "changes the order status to paid" do
      do_post
      FakeBraspag::Order.orders[order_id][:status].should == FakeBraspag::Order::Status::PAID
    end
    
    it "generate crypt params" do
      do_post
      returned_button("input.crypt")["value"].should == "CRYPTO"
    end
  end

  context "cancelling a bill" do
    before { 
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :numpedido => order_id
                                    })
                                    .and_return("CRYPTO")
      
      post FakeBraspag::GENERATE_BILL_URL, :orderId => order_id, :amount => amount_for_post, :paymentMethod => FakeBraspag::Bill::PAYMENT_METHOD_OK 
    }

    def do_post
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :VENDAID => order_id
                                    })
                                    .and_return("CRYPTO")
      
      post FakeBraspag::BILL_URL, :order_id => order_id, :action => "cancel"
    end

    def returned_button(button)
      body_html.css(button)[0]
    end

    it "changes the order status to cancelled" do
      do_post
      FakeBraspag::Order.orders[order_id][:status].should == FakeBraspag::Order::Status::CANCELLED
    end 
    
    it "generate crypt params" do
      do_post
      returned_button("input.crypt")["value"].should == "CRYPTO"
    end
  end
end

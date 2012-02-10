# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  before  do
    ::HTTPI.stub(:post)
  end
  
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }
  let(:body_html) { Nokogiri::HTML last_response.body }
  
  context "Generate EFT" do
    before do
      Braspag::Crypto::JarWebservice.should_receive(:decrypt)
                                    .with("CRYPTO", ["order_id","amount"])
                                    .and_return({
                                      :amount => amount,
                                      :order_id => order_id
                                    })
      
      post FakeBraspag::EFT_URL, :crypt => "CRYPTO"
    end
    
    def returned_button(button)
      body_html.css(button)[0]
    end
    
    it "adds the order to the list of received order" do
      FakeBraspag::Order.orders.should == {
        order_id => {
          :type        => FakeBraspag::PaymentType::EFT,
          :card_number => nil,
          :amount      => amount,
          :ipn_sent    => false,
          :status      => FakeBraspag::Order::Status::PENDING
        }
      }
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
  
  context "paying a eft" do
    before { 
      Braspag::Crypto::JarWebservice.should_receive(:decrypt)
                                    .with("CRYPTO", ["order_id","amount"])
                                    .and_return({
                                      :amount => amount,
                                      :order_id => order_id
                                    })
      
      post FakeBraspag::EFT_URL, :crypt => "CRYPTO"
    }
    
    def do_post
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :numpedido => order_id
                                    })
                                    .and_return("CRYPTO")

      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :VENDAID => order_id
                                    })
                                    .and_return("CRYPTO")
      
      post FakeBraspag::EFT_URL, :order_id => order_id, :action => "pay"
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

  context "cancelling a eft" do
    before { 
      Braspag::Crypto::JarWebservice.should_receive(:decrypt)
                                    .with("CRYPTO", ["order_id","amount"])
                                    .and_return({
                                      :amount => amount,
                                      :order_id => order_id
                                    })
      
      post FakeBraspag::EFT_URL, :crypt => "CRYPTO"
    }
    
    def do_post
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :numpedido => order_id
                                    })
                                    .and_return("CRYPTO")

      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :VENDAID => order_id
                                    })
                                    .and_return("CRYPTO")
      
      post FakeBraspag::EFT_URL, :order_id => order_id, :action => "cancel"
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

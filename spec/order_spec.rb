# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK }
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }

  def do_authorize
    post FakeBraspag::AUTHORIZE_URI, :orderId => order_id, :cardNumber => card_number, :amount => amount_for_post
  end

  context "GetDadosPedido method" do
    let(:body) { Nokogiri::XML last_response.body }

    def returned_node(node)
      body.css(node).text
    end

    def do_post
      post FakeBraspag::DADOS_PEDIDO_URI, :numeroPedido => order_id
    end

    after { FakeBraspag::Order.clear_orders }

    context "when order exists" do
      before do
        do_authorize 
        do_post
      end

      it "returns an XML with the pending status" do
        returned_node("Status").should == FakeBraspag::Order::Status::PENDING
      end

      it "returns an XML with the paid amount" do
        returned_node("Valor").should == amount
      end
    end

    context "when fail retrieve order" do
      it "returns an XML with an empty status" do
        do_post
        returned_node("Status").should == ""
      end
    end
  end
  
  describe "#send_ipn" do
    before do
      do_authorize
    end
    
    it "should mark order as ipn_sent" do
      Braspag::Crypto::JarWebservice.should_receive(:encrypt)
                                    .with({
                                      :NumPedido => order_id
                                    })
                                    .and_return("crypto_string")
      request = mock
      request.should_receive(:body=).with({
        :crypt => "crypto_string"
      })
      
      ::HTTPI::Request.should_receive(:new)
                      .with(Settings.ipn_post)
                      .and_return(request)

      ::HTTPI.should_receive(:post).with(request)
      
      FakeBraspag::Order.send_ipn(order_id)
      
      FakeBraspag::Order.orders.should == {
        order_id => {
          :type        => FakeBraspag::PaymentType::CREDIT_CARD,
          :card_number => card_number,
          :amount      => amount,
          :status      => FakeBraspag::Order::Status::PENDING,
          :ipn_sent    => true
        }
      }
    end
  end
end

# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  context "GetDadosPedido method" do
    let(:order_id) { "12345678" }
    let(:amount_for_post) { "123,45" }
    let(:amount) { "123.45" }
    let(:body) { Nokogiri::XML last_response.body }

    def do_authorize
      post FakeBraspag::AUTHORIZE_URI, :orderId => order_id, :cardNumber => FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK, :amount => amount_for_post
    end

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
end

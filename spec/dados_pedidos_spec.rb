# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }
  let(:body) { Nokogiri::XML last_response.body }
  let(:body_html) { Nokogiri::HTML last_response.body }

  def do_authorize(card_number)
    post FakeBraspag::AUTHORIZE_URI, :orderId => order_id, :cardNumber => card_number, :amount => amount_for_post
  end

  context "GetDadosPedido method" do
    let(:order_id) { "1234" }

    after { FakeBraspag::Order.clear_orders }

    def returned_status
      body.css("Status").text
    end

    def returned_amount
      body.css("Valor").text
    end

    def do_post(order_id)
      post FakeBraspag::DADOS_PEDIDO_URI, :numeroPedido => order_id
    end

    context "when the order has been paid" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_OK }

      before do
        do_authorize card_number 
        do_post order_id
      end

      it "returns an XML with the paid status" do
        returned_status.should == FakeBraspag::DadosPedido::Status::PAID
      end

      it "returns the paid amount" do
        returned_amount.should == amount
      end
    end

    context "when the order is pending" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_OK }  

      before do
        do_authorize card_number 
        do_post order_id
      end

      it "returns an XML with the pending status" do
        returned_status.should == FakeBraspag::DadosPedido::Status::PENDING
      end

      it "returns an XML with the paid amount" do
        returned_amount.should == amount
      end
    end

    context "when the order has been cancelled" do
      let(:card_number) { FakeBraspag::CreditCard::CAPTURE_DENIED }

      before do
        do_authorize card_number 
        do_post order_id
      end

      it "returns an XML with the cancelled status" do
        returned_status.should == FakeBraspag::DadosPedido::Status::CANCELLED
      end

      it "returns an XML with the paid amount" do
        returned_amount.should == amount
      end
    end

    context "when the order has not been authorized or captured" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_OK }

      it "returns an XML with an empty status" do
        do_post order_id
        returned_status.should == ""
      end
    end
  end
end

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

  context "Authorize method" do
    def returned_status
      body.css("status").text
    end

    after { FakeBraspag::Order.clear_orders }

    def returned_order_id
      body.css("transactionId").text
    end

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_OK }

      it "adds the received credit card, amount and order id to the list of authorized requests" do
        do_authorize card_number
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => FakeBraspag::CreditCard::AUTHORIZE_OK,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::PENDING
          }
        }
      end

      it "returns an XML with the sent order id" do
        do_authorize card_number
        returned_order_id.should == order_id
      end

      it "returns an XML with the success status code" do
        do_authorize card_number
        returned_status.should == FakeBraspag::Authorize::Status::AUTHORIZED
      end
    end

    context "when denied" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_DENIED }

      it "does not add the received credit card and order id to the list of received requests" do
        do_authorize card_number
        FakeBraspag::Order.orders.should == {}
      end      

      it "returns an XML with the sent order id" do
        do_authorize card_number
        returned_order_id.should == order_id
      end

      it "returns an XML with the denied status code" do
        do_authorize card_number
        returned_status.should == FakeBraspag::Authorize::Status::DENIED
      end
    end

    context "with capture in the same request" do
      context "when confirmed" do
        let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_OK }

        after { FakeBraspag::Order.clear_orders }

        it "adds the received credit card and order id to the list of authorized requests" do
          do_authorize card_number
          FakeBraspag::Order.orders.should == {
            order_id => {
              :type        => FakeBraspag::PaymentType::CREDIT_CARD,
              :card_number => card_number,
              :amount      => amount,
              :status      => FakeBraspag::Order::Status::PAID
            }
          }
        end

        it "returns an XML with the sent order id" do
          do_authorize card_number
          returned_order_id.should == order_id
        end

        it "returns an XML with the captured status code" do
          do_authorize card_number
          returned_status.should == FakeBraspag::Capture::Status::CAPTURED
        end
      end

      context "denied" do
        let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_DENIED }

        it "adds the received credit card and order id to the list of authorized requests" do
          do_authorize card_number
          FakeBraspag::Order.orders.should == {
            order_id => {
              :card_number => card_number,
              :amount      => amount,
              :status      => FakeBraspag::Order::Status::CANCELLED,
              :type        => FakeBraspag::PaymentType::CREDIT_CARD
            }
          }
        end

        it "returns an XML with the sent order id" do
          do_authorize card_number
          returned_order_id.should == order_id
        end

        it "returns an XML with the captured status code" do
          do_authorize card_number
          returned_status.should == FakeBraspag::Capture::Status::DENIED
        end
      end      
    end
  end

  context "Capture method" do
    def returned_status
      body.css("status").text
    end

    def do_capture
      post FakeBraspag::CAPTURE_URI, :orderId => order_id
    end

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCard::CAPTURE_OK }      

      before { do_authorize card_number }

      it "returns an XML with the captured status code" do
        do_capture 
        returned_status.should == FakeBraspag::Capture::Status::CAPTURED
      end
    end

    context "when denied" do
      let(:card_number) { FakeBraspag::CreditCard::CAPTURE_DENIED }

      before { do_authorize card_number }

      it "returns an XML with the denied status code" do
        do_capture
        returned_status.should == FakeBraspag::Capture::Status::DENIED
      end      
    end
  end
end

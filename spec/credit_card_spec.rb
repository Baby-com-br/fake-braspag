# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }
  let(:body) { Nokogiri::XML last_response.body }

  def do_authorize
    post FakeBraspag::AUTHORIZE_URI, :orderId => order_id, :cardNumber => card_number, :amount => amount_for_post
  end

  def do_capture
    post FakeBraspag::CAPTURE_URI, :orderId => order_id
  end
  
  def returned_node(node)
    body.css(node).text
  end

  after { FakeBraspag::Order.clear_orders }

  context "Authorize method" do
    context "when authorized and captured" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_OK }
      
      it "adds the received credit card, amount and order id to the list of order requests" do
        do_authorize
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::PAID,
            :ipn_sent    => true
          }
        }
      end

      it "send the IPN" do
        FakeBraspag::Order.should_receive(:send_ipn)
        do_authorize
      end

      it "returns an XML with the amount" do
        do_authorize
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_authorize
        returned_node("message").should == FakeBraspag::Authorize::Message::AUTHORIZED
      end

      it "returns an XML with the authorisationNumber" do
        do_authorize
        returned_node("authorisationNumber").should == order_id
      end

      it "returns an XML with the returnCode" do
        do_authorize
        returned_node("returnCode").should == FakeBraspag::Authorize::ReturnCode::AUTHORIZED
      end

      it "returns an XML with the sent order id" do
        do_authorize
        returned_node("transactionId").should == order_id
      end

      it "returns an XML with the success status code" do
        do_authorize
        returned_node("status").should == FakeBraspag::Capture::Status::CAPTURED
      end
    end

    context "when denied" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_DENIED }
      
      it "adds the received credit card, amount and order id to the list of order requests" do
        do_authorize
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::CANCELLED,
            :ipn_sent    => true
          }
        }
      end

      it "send the IPN" do
        FakeBraspag::Order.should_receive(:send_ipn)
        do_authorize
      end

      it "returns an XML with the amount" do
        do_authorize
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_authorize
        returned_node("message").should == FakeBraspag::Authorize::Message::DENIED
      end

      it "returns an XML with the authorisationNumber" do
        do_authorize
        returned_node("authorisationNumber").should == ""
      end

      it "returns an XML with the returnCode" do
        do_authorize
        returned_node("returnCode").should == FakeBraspag::Authorize::ReturnCode::DENIED
      end

      it "returns an XML with the sent order id" do
        do_authorize
        returned_node("transactionId").should == order_id
      end

      it "returns an XML with the success status code" do
        do_authorize
        returned_node("status").should == FakeBraspag::Authorize::Status::DENIED
      end
    end

    context "when authorized and denied capture" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_DENIED }

      it "adds the received credit card, amount and order id to the list of order requests" do
        do_authorize
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::CANCELLED,
            :ipn_sent    => true
          }
        }
      end

      it "send the IPN" do
        FakeBraspag::Order.should_receive(:send_ipn)
        do_authorize
      end

      it "returns an XML with the amount" do
        do_authorize
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_authorize
        returned_node("message").should == FakeBraspag::Authorize::Message::DENIED
      end

      it "returns an XML with the authorisationNumber" do
        do_authorize
        returned_node("authorisationNumber").should == ""
      end

      it "returns an XML with the returnCode" do
        do_authorize
        returned_node("returnCode").should == FakeBraspag::Authorize::ReturnCode::DENIED
      end

      it "returns an XML with the sent order id" do
        do_authorize
        returned_node("transactionId").should == order_id
      end

      it "returns an XML with the success status code" do
        do_authorize
        returned_node("status").should == FakeBraspag::Authorize::Status::DENIED
      end      
    end

    context "when authorized and captured later ok" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK }

      it "adds the received credit card, amount and order id to the list of order requests" do
        do_authorize
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::PENDING,
            :ipn_sent    => false
          }
        }
      end

      it "does not send the IPN" do
        FakeBraspag::Order.should_not_receive(:send_ipn)
        do_authorize
      end

      it "returns an XML with the amount" do
        do_authorize
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_authorize
        returned_node("message").should == FakeBraspag::Authorize::Message::AUTHORIZED
      end

      it "returns an XML with the authorisationNumber" do
        do_authorize
        returned_node("authorisationNumber").should == order_id
      end

      it "returns an XML with the returnCode" do
        do_authorize
        returned_node("returnCode").should == FakeBraspag::Authorize::ReturnCode::AUTHORIZED
      end

      it "returns an XML with the sent order id" do
        do_authorize
        returned_node("transactionId").should == order_id
      end

      it "returns an XML with the success status code" do
        do_authorize
        returned_node("status").should == FakeBraspag::Authorize::Status::AUTHORIZED
      end
    end
    
    context "when authorized and captured later denied" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_LATER_DENIED }

      it "adds the received credit card, amount and order id to the list of order requests" do
        do_authorize
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::PENDING,
            :ipn_sent    => false
          }
        }
      end

      it "does not send the IPN" do
        FakeBraspag::Order.should_not_receive(:send_ipn)
        do_authorize
      end

      it "returns an XML with the amount" do
        do_authorize
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_authorize
        returned_node("message").should == FakeBraspag::Authorize::Message::AUTHORIZED
      end

      it "returns an XML with the authorisationNumber" do
        do_authorize
        returned_node("authorisationNumber").should == order_id
      end

      it "returns an XML with the returnCode" do
        do_authorize
        returned_node("returnCode").should == FakeBraspag::Authorize::ReturnCode::AUTHORIZED
      end

      it "returns an XML with the sent order id" do
        do_authorize
        returned_node("transactionId").should == order_id
      end

      it "returns an XML with the success status code" do
        do_authorize
        returned_node("status").should == FakeBraspag::Authorize::Status::AUTHORIZED
      end
    end
  end

  context "Capture method" do
    before { do_authorize }

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_LATER_OK }

      it "change the received credit card, amount and order id to the list of order requests" do
        do_capture
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::PAID,
            :ipn_sent    => true
          }
        }
      end

      it "send the IPN" do
        FakeBraspag::Order.should_receive(:send_ipn)
        do_capture
      end

      it "returns an XML with the amount" do
        do_capture
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_capture
        returned_node("message").should == FakeBraspag::Capture::Message::CAPTURED
      end

      it "returns an XML with the returnCode" do
        do_capture
        returned_node("returnCode").should == FakeBraspag::Capture::ReturnCode::CAPTURED
      end

      it "returns an XML with the success status code" do
        do_capture
        returned_node("status").should == FakeBraspag::Capture::Status::CAPTURED
      end
    end

    context "when denied" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_AND_CAPTURE_LATER_DENIED }

      it "change the received credit card, amount and order id to the list of order requests" do
        do_capture
        FakeBraspag::Order.orders.should == {
          order_id => {
            :type        => FakeBraspag::PaymentType::CREDIT_CARD,
            :card_number => card_number,
            :amount      => amount,
            :status      => FakeBraspag::Order::Status::CANCELLED,
            :ipn_sent    => true
          }
        }
      end

      it "send the IPN" do
        FakeBraspag::Order.should_receive(:send_ipn)
        do_capture
      end

      it "returns an XML with the amount" do
        do_capture
        returned_node("amount").should == amount
      end

      it "returns an XML with the message" do
        do_capture
        returned_node("message").should == FakeBraspag::Capture::Message::DENIED
      end

      it "returns an XML with the returnCode" do
        do_capture
        returned_node("returnCode").should == FakeBraspag::Capture::ReturnCode::DENIED
      end

      it "returns an XML with the success status code" do
        do_capture
        returned_node("status").should == FakeBraspag::Capture::Status::DENIED
      end
    end
  end
end

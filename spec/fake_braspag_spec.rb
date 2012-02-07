# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  let(:order_id) { "12345678" }
  let(:body) { Nokogiri::XML last_response.body }

  def do_authorize(card_number)
    post FakeBraspag::AUTHORIZE_URI, :order_id => order_id, :card_number => card_number
  end

  def returned_status
    body.css("status").text
  end

  context "Authorize method" do
    after { FakeBraspag::App.clear_requests }

    def returned_order_id
      body.css("transactionId").text
    end

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_OK }

      it "adds the received credit card and order id to the list of received requests" do
        do_authorize card_number
        FakeBraspag::App.received_requests.should == {order_id => FakeBraspag::CreditCards::AUTHORIZE_OK}
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
      let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_DENIED }

      it "does not add the received credit card and order id to the list of received requests" do
        do_authorize card_number
        FakeBraspag::App.received_requests.should == {}
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
        let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_AND_CAPTURE_OK }

        it "does not add the received credit card and order id to the list of received requests" do
          do_authorize card_number
          FakeBraspag::App.received_requests.should == {}
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
        let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_AND_CAPTURE_DENIED }

        it "does not add the received credit card and order id to the list of received requests" do
          do_authorize card_number
          FakeBraspag::App.received_requests.should == {}
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
    def do_capture
      post FakeBraspag::CAPTURE_URI, :order_id => order_id
    end

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCards::CAPTURE_OK }      

      before { do_authorize card_number }

      it "returns an XML with the captured status code" do
        do_capture 
        returned_status.should == FakeBraspag::Capture::Status::CAPTURED
      end
    end

    context "when denied" do
      let(:card_number) { FakeBraspag::CreditCards::CAPTURE_DENIED }

      before { do_authorize card_number }

      it "returns an XML with the denied status code" do
        do_capture
        returned_status.should == FakeBraspag::Capture::Status::DENIED
      end      
    end
  end
end

# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  context "Authorize method" do
    let(:order_id) { "12345678" }

    after { FakeBraspag::App.clear_requests }

    def do_post(card_number)
      post FakeBraspag::AUTHORIZE_URI, :order_id => order_id, :card_number => card_number
    end

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_OK }

      it "adds the received credit card and order id to the list of received requests" do
        do_post card_number
        FakeBraspag::App.received_requests.should == {order_id => FakeBraspag::CreditCards::AUTHORIZE_OK}
      end

      it "returns an XML with the sent order id" do
        do_post card_number
        Nokogiri::XML(last_response.body).css("transactionId").text.should == order_id
      end

      it "returns an XML with the success status code" do
        do_post card_number
        Nokogiri::XML(last_response.body).css("status").text.should == FakeBraspag::Authorize::Status::AUTHORIZED
      end
    end

    context "when denied" do
      let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_DENIED }

      it "does not add the received credit card and order id to the list of received requests" do
        do_post card_number
        FakeBraspag::App.received_requests.should == {}
      end      

      it "returns an XML with the sent order id" do
        do_post card_number
        Nokogiri::XML(last_response.body).css("transactionId").text.should == order_id
      end

      it "returns an XML with the denied status code" do
        do_post card_number
        Nokogiri::XML(last_response.body).css("status").text.should == FakeBraspag::Authorize::Status::DENIED
      end
    end

    context "with capture in the same request" do
      context "when confirmed" do
        let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_AND_CAPTURE_OK }

        it "does not add the received credit card and order id to the list of received requests" do
          do_post card_number
          FakeBraspag::App.received_requests.should == {}
        end

        it "returns an XML with the sent order id" do
          do_post card_number
          Nokogiri::XML(last_response.body).css("transactionId").text.should == order_id
        end

        it "returns an XML with the captured status code" do
          do_post card_number
          Nokogiri::XML(last_response.body).css("status").text.should == FakeBraspag::Capture::Status::CAPTURED
        end
      end

      context "denied" do
        let(:card_number) { FakeBraspag::CreditCards::AUTHORIZE_AND_CAPTURE_DENIED }

        it "does not add the received credit card and order id to the list of received requests" do
          do_post card_number
          FakeBraspag::App.received_requests.should == {}
        end

        it "returns an XML with the sent order id" do
          do_post card_number
          Nokogiri::XML(last_response.body).css("transactionId").text.should == order_id
        end

        it "returns an XML with the captured status code" do
          do_post card_number
          Nokogiri::XML(last_response.body).css("status").text.should == FakeBraspag::Capture::Status::DENIED
        end
      end      
    end
  end

  context "Capture method" do
    context "when authorized" do
      
    end

    context "when denied" do
      
    end
  end
end

# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  context "Authorize method" do
    let(:order_id) { "12345678" }

    context "when authorized" do
      def do_post
        post FakeBraspag::AUTHORIZE_URI, :order_id => order_id, :card_number => FakeBraspag::CreditCards::AUTHORIZE_OK
      end

      it "adds the received credit card and order id to the list received requests" do
        do_post
        FakeBraspag::App.received_requests.should == {order_id => FakeBraspag::CreditCards::AUTHORIZE_OK}
      end

      it "returns an XML with the sent order id" do
        do_post
        Nokogiri::XML(last_response.body).css("transactionId").text.should == order_id
      end

      it "returns an XML with the success status code" do
        do_post
        Nokogiri::XML(last_response.body).css("status").text.should == FakeBraspag::Authorize::Status::AUTHORIZED
      end
    end

    context "when denied" do
      
    end

    context "with capture in the same request" do
      context "when authorized" do
        
      end

      context "denied" do
        
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

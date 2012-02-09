# encoding: utf-8
require 'spec_helper'

describe FakeBraspag::App do
  let(:order_id) { "12345678" }
  let(:amount_for_post) { "123,45" }
  let(:amount) { "123.45" }
  let(:body) { Nokogiri::XML last_response.body }

  def do_authorize(card_number)
    post FakeBraspag::AUTHORIZE_URI, :orderId => order_id, :cardNumber => card_number, :amount => amount_for_post
  end

  context "Authorize method" do
    def returned_status
      body.css("status").text
    end

    after { FakeBraspag::App.clear_authorized_requests }

    def returned_order_id
      body.css("transactionId").text
    end

    context "when authorized" do
      let(:card_number) { FakeBraspag::CreditCard::AUTHORIZE_OK }

      it "adds the received credit card, amout and order id to the list of authorized requests" do
        do_authorize card_number
        FakeBraspag::App.authorized_requests.should == {order_id => {:card_number => FakeBraspag::CreditCard::AUTHORIZE_OK, :amount => amount_for_post}}
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
        FakeBraspag::App.authorized_requests.should == {}
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

        after { FakeBraspag::App.clear_captured_requests }

        it "adds the received credit card and order id to the list of authorized requests" do
          do_authorize card_number
          FakeBraspag::App.authorized_requests.should == {order_id => {:card_number => card_number, :amount => amount_for_post}}
        end

        it "adds the order id to the list of captured orders" do
          do_authorize card_number
          FakeBraspag::App.captured_requests.should == [order_id]
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
          FakeBraspag::App.authorized_requests.should == {order_id => {:card_number => card_number, :amount => amount_for_post}}
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

  context "GetDadosPedido method" do
    let(:order_id) { "1234" }

    after do
      FakeBraspag::App.clear_captured_requests 
      FakeBraspag::App.clear_authorized_requests
    end

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

  context "CreateBoleto method" do
    before { do_post payment_method }

    def do_post(payment_method)
      post FakeBraspag::BILL_URL, :orderId => order_id, :amount => amount_for_post, :paymentMethod => payment_method
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
    end
  end
end

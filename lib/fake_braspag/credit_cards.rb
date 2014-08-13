require 'active_support/core_ext/hash/conversions'

module FakeBraspag
  class CreditCards < Sinatra::Base
    post '/CartaoProtegido.asmx' do
      operation, data = parse_soap_request

      case operation
      when 'SaveCreditCard'
        save_credit_card(data['saveCreditCardRequestWS'])
      when 'JustClickShop'
        # TODO
      else
        # TODO 400 - bad request, unsupported method
      end
    end

    get '/CartaoProtegido.asmx' do
      erb :protected_credit_card_wsdl, format: :xml
    end

    private

    # TODO: doc
    # TODO: handle invalid input
    def parse_soap_request
      soap_request = Hash.from_xml(request.body.read)
      request_data = soap_request['Envelope']['Body']
      operation = request_data.keys.first

      [ operation, request_data[operation] ]
    end

    # TODO: doc
    def save_credit_card(credit_card_params)
      card = FakeBraspag::CreditCard.new(credit_card_params)

      if card.valid?
        builder :save_credit_card_success, locals: { card: card }
      else
        builder :save_credit_card_failure, locals: {
          error_code: 732,
          error_message: 'SaveCreditCardRequestId can not be null'
        }
      end
    end
  end
end

require 'active_support/core_ext/hash/conversions'

module FakeBraspag
  class CreditCards < Sinatra::Base
    post '/CartaoProtegido.asmx' do
      operation, data = parse_soap_request

      case operation
      when 'SaveCreditCard'
        save_credit_card(data['saveCreditCardRequestWS'])
      when 'JustClickShop'
        just_click_shop(data['justClickShopRequestWS'])
      when 'GetCreditCard'
        get_protected_credit_card
      end
    end

    get '/CartaoProtegido.asmx' do
      erb :protected_credit_card_wsdl, format: :xml
    end

    private

    # Internal: Extract operation data from the request SOAP Envelope (XML).
    #
    # Examples
    #
    #   Given the following request body:
    #
    #   <env:Envelope>
    #     <env:Body>
    #       <tns:SaveCreditCard>
    #         <tns:saveCreditCardRequestWS>
    #           <tns:Key>Value</tns:Key>
    #         </tns:saveCreditCardRequestWS>
    #       </tns:SaveCreditCard>
    #     </env:Body>
    #   </env:Envelope>
    #
    #   parse_soap_request
    #   # => [ 'SaveCreditCard', {'Key' => 'Value'} ]
    #
    # Returns an operation identifier and an attributes Hash.
    def parse_soap_request
      soap_request = Hash.from_xml(request.body.read)
      request_data = soap_request['Envelope']['Body']
      operation = request_data.keys.first

      [ operation, request_data[operation] ]
    end

    def save_credit_card(credit_card_params)
      card = FakeBraspag::CreditCard.new(credit_card_params)

      if ResponseToggler.enabled?('save_credit_card') && card.save
        builder :save_credit_card_success, locals: { card: card }
      else
        builder :save_credit_card_failure, locals: { card: card }
      end
    end

    def just_click_shop(authorization_params)
      card = FakeBraspag::CreditCard.new(authorization_params)
      order = Order.new('orderId' => authorization_params['OrderId'], 'amount' => authorization_params['Amount'])

      if ResponseToggler.enabled?('just_click_shop') && card.just_click_shop
        order.authorize!
        order.capture!

        builder :just_click_shop_success, locals: { card: card }
      else
        builder :just_click_shop_failure, locals: { card: card }
      end
    end

    def get_protected_credit_card
      if ResponseToggler.enabled?('get_credit_card')
        builder :get_credit_card_success
      else
        builder :get_credit_card_failure
      end
    end
  end
end

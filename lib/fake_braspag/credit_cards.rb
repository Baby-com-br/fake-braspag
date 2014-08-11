module FakeBraspag
  class CreditCards < Sinatra::Base
    post '/CartaoProtegido.asmx' do
      xml = request.body.read
      method = xml[ /<env:Body>\s*<tns:(.+?)>/, 1 ]

      case method
      when 'SaveCreditCard'
        card = FakeBraspag::CreditCard.new(xml)

        if card.valid?
          builder :save_credit_card_success, locals: { card: card }
        else
          # TODO
        end
      when 'JustClickShop'
        # TODO
      else
        # TODO
      end
    end

    get '/CartaoProtegido.asmx' do
      erb :protected_credit_card_wsdl, format: :xml
    end
  end
end

module FakeBraspag
  class CreditCards < Sinatra::Base
    get '/CartaoProtegido.asmx' do
      erb :protected_credit_card_wsdl, format: :xml
    end
  end
end

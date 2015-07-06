require 'digest'

class SalePresenter
  delegate :id, to: :@order

  def initialize(order)
    @order = order
  end

  def amount
    (@order.amount.to_f * 100).to_i
  end

  def save_card
    @order.saveCard
  end

  def card_number
    "%s******%s" % [@order.cardNumber[0..5], @order.cardNumber[12, 15]] if @order.cardNumber.present?
  end

  def card_token
    Digest::SHA1.hexdigest(@order.cardNumber.to_s) if save_card
  end

  def reason_code
    @order.authorized? ? 0 : 7
  end

  def reason_message
    @order.authorized? ? "Successful" : "Denied"
  end

  def status
    @order.authorized? ? 1 : 3
  end

  def provider_return_code
    @order.authorized? ? "4" : "2"
  end

  def provider_return_message
    @order.authorized? ? "Operation Successful" : "Not Authorized"
  end
end

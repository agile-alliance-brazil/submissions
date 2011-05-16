class PaymentNotification < ActiveRecord::Base
  belongs_to :attendee
  serialize :params
  
  validates_existence_of :attendee
  
  after_create :mark_attendee_as_paid
  
  def self.from_paypal_params(params)
    params.slice(:settle_amount, :settle_currency, :payer_email).merge({
      :params => params,
      :attendee_id => params[:invoice],
      :status => params[:payment_status],
      :transaction_id => params[:txn_id]
    })
  end
  
  private
  def mark_attendee_as_paid
    if status == "Completed"
      attendee.pay
    end
  end
end
# encoding: UTF-8
class PaymentNotification < ActiveRecord::Base
  belongs_to :invoicer, :polymorphic => true
  serialize :params
  
  validates_existence_of :invoicer
  
  after_create :mark_invoicer_as_paid
  
  def self.from_paypal_params(params)
    params.slice(:settle_amount, :settle_currency, :payer_email).merge({
      :params => params,
      :invoicer_id => params[:invoice],
      :invoicer_type => params[:custom],
      :status => params[:payment_status],
      :transaction_id => params[:txn_id],
      :notes => params[:memo]
    })
  end
  
  private
  def mark_invoicer_as_paid
    if status == "Completed" && params_valid?
      invoicer.confirm
    else
      Airbrake.notify(
        :error_class   => "Failed Payment Notification",
        :error_message => "Failed Payment Notification for invoicer: #{invoicer.inspect}",
        :parameters    => params
      )
    end
  end
  
  def params_valid?
    params[:secret] == AppConfig[:paypal][:secret] &&
    params[:receiver_email] == AppConfig[:paypal][:email] &&
    params[:mc_currency] == AppConfig[:paypal][:currency] &&
    BigDecimal.new(params[:mc_gross].to_s) == BigDecimal.new(invoicer.registration_fee.to_s)
  end
end

# encoding: UTF-8
class PaymentNotificationsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action
  protect_from_forgery :except => [:create]
  
  def create
    PaymentNotification.create!(PaymentNotification.from_paypal_params(params))
    render :nothing => true
  end
end

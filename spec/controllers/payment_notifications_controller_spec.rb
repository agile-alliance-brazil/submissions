require 'spec_helper'

describe PaymentNotificationsController do
  describe "POST create" do
    it "should create PaymentNotification" do
      attendee = Factory(:attendee)
      
      lambda {
        post :create, :txn_id => "ABCABC", :invoice => attendee.id, :payment_status => "Completed"
      }.should change(PaymentNotification, :count).by(1)      
    end
  end
end

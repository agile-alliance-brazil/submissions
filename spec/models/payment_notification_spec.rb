require 'spec_helper'

describe PaymentNotification do
  context "associations" do
    should_belong_to :attendee
  end
  
  context "validations" do
    should_validate_existence_of :attendee
  end
  
  context "callbacks" do
    it "should mark attendee as paid after create if status is Completed" do
      attendee = Factory(:attendee)
      attendee.should be_pending
      
      payment_notification = Factory(:payment_notification, :status => "Completed", :attendee => attendee)
      attendee.should be_paid
    end

    it "should not mark attendee as paid after create if status is not Completed" do
      attendee = Factory(:attendee)
      attendee.should be_pending
      
      payment_notification = Factory(:payment_notification, :status => "Failed", :attendee => attendee)
      attendee.should be_pending
    end
  end
  
  it "should translate params from paypal into attributes" do
    paypal_params = {
      :payment_status => "Completed",
      :txn_id => "AAABBBCCC",
      :invoice => 2
    }
    PaymentNotification.from_paypal_params(paypal_params).should == {
      :params => paypal_params,
      :status => "Completed",
      :transaction_id =>  "AAABBBCCC",
      :attendee_id => 2
    }
  end
end

require 'spec_helper'

describe PaypalHelper do
  describe "paypal_params" do
    it "should build params from attendee" do
      attendee = Factory(:attendee, :registration_date => Time.zone.local(2011, 5, 15))
      
      params = helper.paypal_params(attendee, 'return_url', 'notify_url')
      
      params['amount_1'].should == attendee.base_price
      params['item_name_1'].should == "Tipo de inscrição: Individual"
      params['quantity_1'].should == 1
      params['item_number_1'].should == attendee.registration_type.id
      
      params[:return].should == 'return_url'
      params[:cancel_return].should == 'return_url'
      params[:notify_url].should == 'notify_url'
    end
  end
end

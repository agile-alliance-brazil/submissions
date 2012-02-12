# encoding: UTF-8
require 'spec_helper'

describe PaypalHelper do
  describe "add_config_vars" do
    it "should add return url and notification url" do
      params = {}
      helper.add_config_vars(params, 'return_url', 'notify_url')
      
      params[:return].should == 'return_url'
      params[:cancel_return].should == 'return_url'
      params[:notify_url].should == 'notify_url'
    end
  end
end

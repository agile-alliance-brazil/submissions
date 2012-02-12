# encoding: UTF-8
require 'spec_helper'

describe PreRegistrationLoader do
  before(:each) do
    Rails.logger.stubs(:info)
    Rails.logger.stubs(:flush)
  end
  
  it "should raise error if there is no file to load" do
    lambda {PreRegistrationLoader.new(File.dirname(__FILE__) + "/../resources/non_existing.csv")}.should raise_error("File 'non_existing.csv' does not exist.")
  end
  
  it "should raise error if file is not in the expected format" do
    lambda {PreRegistrationLoader.new(File.dirname(__FILE__) + "/../resources/invalid.csv")}.should raise_error("File 'invalid.csv' is not in the expected format.")
  end
  
  it "should load pre registrations from file" do
    loader = PreRegistrationLoader.new(File.dirname(__FILE__) + "/../resources/valid.csv")
    loader.pre_registrations.size.should == 5
    loader.pre_registrations[0].email.should == 'alexandregazola@gmail.com'
  end
end

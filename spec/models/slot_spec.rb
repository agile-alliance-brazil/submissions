# encoding: UTF-8
require 'spec_helper'

describe Slot do
  
  context "validations" do
    it { should validate_presence_of :start_at }
    it { should validate_presence_of :end_at }
  end
  
  context "associations" do
    it { should belong_to :session }
    it { should belong_to :track }
  end

end

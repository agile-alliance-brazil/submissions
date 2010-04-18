require 'spec/spec_helper'

describe Slot do
  
  context "validations" do
    should_validate_presence_of :start_at
    should_validate_presence_of :end_at
  end
  
  context "associations" do
    should_belong_to :session
    should_belong_to :track
  end

end

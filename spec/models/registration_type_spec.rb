require 'spec_helper'

describe RegistrationType do
  it "should provide translated options for select" do
    RegistrationType.options_for_select.should include(["Estudante", 1])
    RegistrationType.options_for_select.should include(["Individual", 3])
    RegistrationType.options_for_select.size.should == 2
  end
  
  it "should provide valid values" do
    RegistrationType.valid_values.should == [1, 3]
  end
  
  context "associations" do
    should_belong_to :conference
    should_have_many :registration_prices
  end
end

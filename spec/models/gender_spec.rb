require 'spec_helper'

describe Gender do
  it "should provide translated options for select" do
    Gender.options_for_select.should include(['M', 'Masculino'])
    Gender.options_for_select.should include(['F', 'Feminino'])
    Gender.options_for_select.size.should == 2
  end
  
  it "should provide valid values" do
    Gender.valid_values.should == %w(M F)
  end
end

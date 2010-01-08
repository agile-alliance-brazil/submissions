require File.dirname(__FILE__) + '/../spec_helper'

describe Track do

  describe "validations" do

    it "should require mandatory fields" do
      track = Track.new
      track.should_not be_valid
      track.errors.on(:title).should == "não pode ficar em branco"
      track.errors.on(:description).should == "não pode ficar em branco"
      
      track = Track.new(:title => "Engineering", :description => "blah")
      track.should be_valid
    end
    
  end

end

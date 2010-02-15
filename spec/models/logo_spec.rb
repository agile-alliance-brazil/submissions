require 'spec/spec_helper'

describe Logo do
  context "logo variations" do
    before(:each) do
      @logo1 = Factory(:logo, :format => 'png')
      @logo2 = Factory(:logo, :format => 'gif')
    end
    
    it "- big and coloured (default)" do
      @logo1.to_filename.should == "logo#{@logo1.id}_500.png"
      @logo1.to_filename(:size => :big).should == "logo#{@logo1.id}_500.png"
      @logo2.to_filename.should == "logo#{@logo2.id}_500.gif"
      @logo2.to_filename(:size => :big).should == "logo#{@logo2.id}_500.gif"
    end
    
    it "- small and coloured" do
      @logo1.to_filename(:size => :small).should == "logo#{@logo1.id}_200.png"
      @logo2.to_filename(:size => :small).should == "logo#{@logo2.id}_200.gif"
    end

    it "- small and black&white" do
      @logo1.to_filename(:size => :small, :color => false).should == "logo#{@logo1.id}_200_bw.png"
      @logo2.to_filename(:size => :small, :color => false).should == "logo#{@logo2.id}_200_bw.gif"
    end

    it "- big and black&white" do
      @logo1.to_filename(:size => :big, :color => false).should == "logo#{@logo1.id}_500_bw.png"
      @logo1.to_filename(:color => false).should == "logo#{@logo1.id}_500_bw.png"
      @logo2.to_filename(:size => :big, :color => false).should == "logo#{@logo2.id}_500_bw.gif"
      @logo2.to_filename(:color => false).should == "logo#{@logo2.id}_500_bw.gif"
    end
  end
end
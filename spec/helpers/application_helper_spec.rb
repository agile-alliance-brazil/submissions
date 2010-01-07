require 'spec/spec_helper'

describe ApplicationHelper do
  describe "fix URL" do
    it "should prepend 'http://' if missing" do
      helper.prepend_http('www.dtsato.com').should == 'http://www.dtsato.com'
    end
    
    it "should not change URL if starts with 'http://'" do
      helper.prepend_http('http://dtsato.com').should == 'http://dtsato.com'
    end
    
    it "should ignore case when fixing" do
      helper.prepend_http('HTTP://dtsato.com/some/path-01').should == 'HTTP://dtsato.com/some/path-01'
    end
  end
end

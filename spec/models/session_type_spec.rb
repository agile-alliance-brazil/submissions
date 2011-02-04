require 'spec_helper'

describe SessionType do
  
  context "validations" do
    should_validate_presence_of :title
    should_validate_presence_of :description
  end
  
  context "associations" do
    should_have_many :sessions
  end
  
end

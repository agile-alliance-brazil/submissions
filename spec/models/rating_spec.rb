require 'spec/spec_helper'

describe Rating do
  context "validations" do
    should_validate_presence_of :title
  end
  
  context "associations" do
    should_have_many :reviews
  end
end

# encoding: UTF-8
require 'spec_helper'

describe Outcome do
  context "validations" do
    should_validate_presence_of :title
  end
  
  context "associations" do
    should_have_many :review_decisions
  end
end

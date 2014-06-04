# encoding: UTF-8
require 'spec_helper'

describe Outcome, type: :model do
  context "validations" do
    it { should validate_presence_of :title }
  end
  
  context "associations" do
    it { should have_many :review_decisions }
  end
end

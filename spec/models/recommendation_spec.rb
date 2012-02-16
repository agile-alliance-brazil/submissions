# encoding: UTF-8
require 'spec_helper'

describe Recommendation do
  context "validations" do
    it { should validate_presence_of :title }
  end
end

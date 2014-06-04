# encoding: UTF-8
require 'spec_helper'

describe Rating, type: :model do
  context "validations" do
    it { should validate_presence_of :title }
  end
end

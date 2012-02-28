# encoding: UTF-8
require 'spec_helper'

describe Conference do
  context "associations" do
    it { should have_many :tracks }
  end
end

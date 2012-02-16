# encoding: UTF-8
require 'spec_helper'

describe RegistrationPrice do
  context "associations" do
    it { should belong_to :registration_type }
    it { should belong_to :registration_period }
  end
end

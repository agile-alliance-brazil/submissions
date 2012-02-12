# encoding: UTF-8
require 'spec_helper'

describe RegistrationPrice do
  context "associations" do
    should_belong_to :registration_type
    should_belong_to :registration_period
  end
end

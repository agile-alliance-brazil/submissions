require 'spec_helper'

describe RegistrationType do  
  context "associations" do
    should_belong_to :conference
    should_have_many :registration_prices
  end
end

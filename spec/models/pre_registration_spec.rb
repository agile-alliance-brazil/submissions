require 'spec_helper'

describe PreRegistration do
  context "association" do
    should_belong_to :conference
  end
end
require 'spec_helper'

describe Rating do
  context "validations" do
    should_validate_presence_of :title
  end
end

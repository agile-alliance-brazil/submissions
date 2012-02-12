# encoding: UTF-8
require 'spec_helper'

describe Recommendation do
  context "validations" do
    should_validate_presence_of :title
  end
end

# encoding: utf-8
require 'spec_helper'

describe Course do
  context "validations" do
    should_validate_presence_of :name
    should_validate_presence_of :full_name
  end
  
  context "associations" do
    should_belong_to :conference
    should_have_many :course_prices
  end
end
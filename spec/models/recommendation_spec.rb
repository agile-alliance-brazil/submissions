# encoding: UTF-8
require 'spec_helper'

describe Recommendation do
  context "validations" do
    it { should validate_presence_of :title }
  end

  Recommendation.all_titles.each do |title|
    it "should determine if it's #{title}" do
      recommendation = FactoryGirl.build(:recommendation, :title => "recommendation.#{title}.title")
      recommendation.send(:"#{title}?").should be_true
      recommendation = FactoryGirl.build(:recommendation, :title => 'recommendation.other.title')
      recommendation.send(:"#{title}?").should be_false
    end
  end
end

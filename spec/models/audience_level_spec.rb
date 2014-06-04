# encoding: UTF-8
require 'spec_helper'

describe AudienceLevel, type: :model do

  context "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
  end
  
  context "associations" do
    it { should have_many :sessions }
    it { should belong_to :conference }
  end
end

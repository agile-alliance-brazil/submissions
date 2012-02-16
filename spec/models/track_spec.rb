# encoding: UTF-8
require 'spec_helper'

describe Track do
  
  context "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
  end
  
  context "associations" do
    it { should have_many :sessions }
    it { should have_many(:track_ownerships).class_name('Organizer') }
    it { should have_many(:organizers).through(:track_ownerships) }
  end

end

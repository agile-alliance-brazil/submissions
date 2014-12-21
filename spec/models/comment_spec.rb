# encoding: UTF-8
require 'spec_helper'

describe Comment, type: :model do
  it_should_trim_attributes Comment, :comment
  
  context "associations" do
    it { should belong_to :user }
    it { should belong_to :commentable }
  end
  
  context "validations" do
    it { should validate_presence_of :comment }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :commentable_id }

    it { should ensure_length_of(:comment).is_at_most(1000) }
  end
end

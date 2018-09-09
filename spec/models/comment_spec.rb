# frozen_string_literal: true

require 'spec_helper'

describe Comment, type: :model do
  it_should_trim_attributes Comment, :comment

  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :commentable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :comment }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :commentable_id }
    it { is_expected.to validate_presence_of :commentable_type }

    it { is_expected.to validate_length_of(:comment).is_at_most(1000) }
  end
end

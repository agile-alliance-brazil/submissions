# frozen_string_literal: true

require 'spec_helper'

describe Outcome, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
  end

  describe 'associations' do
    it { is_expected.to have_many :review_decisions }
  end
end

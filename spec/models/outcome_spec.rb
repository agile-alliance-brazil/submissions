# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe Outcome, type: :model do
  context 'validations' do
    it { should validate_presence_of :title }
  end

  context 'associations' do
    it { should have_many :review_decisions }
  end
end

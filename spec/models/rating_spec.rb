# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe Rating, type: :model do
  context 'validations' do
    it { should validate_presence_of :title }
  end
end

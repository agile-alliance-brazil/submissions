# frozen_string_literal: true

require 'spec_helper'

describe Rating, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
  end
end

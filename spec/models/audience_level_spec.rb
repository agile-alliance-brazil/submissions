# frozen_string_literal: true

require 'spec_helper'

describe AudienceLevel, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :conference }
    # TODO: Validations of languages
  end

  describe 'associations' do
    it { is_expected.to have_many :sessions }
    it { is_expected.to belong_to :conference }
    it { is_expected.to have_many :translated_contents }
  end
end

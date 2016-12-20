# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe AudienceLevel, type: :model do
  context 'validations' do
    it { should validate_presence_of :conference }
    # TODO: Validations of languages
  end

  context 'associations' do
    it { should have_many :sessions }
    it { should belong_to :conference }
    it { should have_many :translated_contents }
  end
end

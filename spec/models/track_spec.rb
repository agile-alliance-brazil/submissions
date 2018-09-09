# frozen_string_literal: true

require 'spec_helper'

describe Track, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :conference }
    # TODO: Validations of languages
  end

  describe 'associations' do
    it { is_expected.to belong_to :conference }
    it { is_expected.to have_many :sessions }
    it { is_expected.to have_many(:track_ownerships).class_name('Organizer') }
    it { is_expected.to have_many(:organizers).through(:track_ownerships) }
    it { is_expected.to have_many(:translated_contents) }
  end

  it 'determines if it is experience report' do
    track = FactoryBot.build(:track, title: 'tracks.experience_reports.title')
    expect(track).to be_experience_report
    track = FactoryBot.build(:track, title: 'tracks.management.title')
    expect(track).not_to be_experience_report
  end
end

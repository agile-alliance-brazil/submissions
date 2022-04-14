# frozen_string_literal: true

describe UserConference, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :conference_id }
  end
end

# encoding: UTF-8

RSpec.describe SessionsHelper, type: :helper do

  describe '#all_durations_for' do
    context 'empty session types' do
      subject { helper.all_durations_for([]) }
      it { is_expected.to be_empty }
    end

    context 'single session types' do
      subject { helper.all_durations_for([FactoryGirl.build(:session_type, valid_durations: [10, 20])]) }
      it { is_expected.to eq [10, 20] }
    end

    context 'multiple session types' do
      it 'merges durations' do
        durations = helper.all_durations_for([
          FactoryGirl.build(:session_type, valid_durations: [10, 20]),
          FactoryGirl.build(:session_type, valid_durations: [30, 40]),
        ])
        expect(durations).to eq([10, 20, 30, 40])
      end

      it 'removes duplicates' do
        durations = helper.all_durations_for([
          FactoryGirl.build(:session_type, valid_durations: [10, 20]),
          FactoryGirl.build(:session_type, valid_durations: [20, 30]),
        ])
        expect(durations).to eq([10, 20, 30])
      end

      it 'sorts durations' do
        durations = helper.all_durations_for([
          FactoryGirl.build(:session_type, valid_durations: [20, 40]),
          FactoryGirl.build(:session_type, valid_durations: [30, 10]),
        ])
        expect(durations).to eq([10, 20, 30, 40])
      end
    end
  end

  describe '#options_for_durations' do
    it 'returns human readable collection of durations' do
      options = helper.options_for_durations([
        FactoryGirl.build(:session_type, valid_durations: [20, 40]),
        FactoryGirl.build(:session_type, valid_durations: [10, 20]),
      ])
      expect(options).to eq([["10 #{t('generic.minutes')}", 10], ["20 #{t('generic.minutes')}", 20], ["40 #{t('generic.minutes')}", 40]])
    end
  end

  describe '#durations_to_hide' do
    it 'returns durations to hide as strings' do
      session_type_1 = FactoryGirl.create(:session_type, valid_durations: [20, 40])
      session_type_2 = FactoryGirl.create(:session_type, valid_durations: [10, 20])
      durations_to_hide = helper.durations_to_hide([session_type_1, session_type_2])
      expect(durations_to_hide[session_type_1.id]).to eq(['10'])
      expect(durations_to_hide[session_type_2.id]).to eq(['40'])
    end

    it 'hides default option when session type only accepts a single duration' do
      session_type_1 = FactoryGirl.create(:session_type, valid_durations: [40])
      session_type_2 = FactoryGirl.create(:session_type, valid_durations: [10, 20])
      durations_to_hide = helper.durations_to_hide([session_type_1, session_type_2])
      expect(durations_to_hide[session_type_1.id]).to eq(['10', '20', ''])
      expect(durations_to_hide[session_type_2.id]).to eq(['40'])
    end
  end

  describe '#duration_mins_hint' do
    it 'generates hint from session types in portuguese' do
      I18n.with_locale('pt') do
        hint = helper.duration_mins_hint([
          FactoryGirl.build(:session_type, title: 'session_types.talk.title', valid_durations: [20, 40]),
          FactoryGirl.build(:session_type, title: 'session_types.experience_report.title', valid_durations: [10]),
          FactoryGirl.build(:session_type, title: 'session_types.hands_on.title', valid_durations: [30, 20])
        ])
        expect(hint).to eq('Palestras devem ter duração de 20 ou 40 minutos, relatos de experiência 10 minutos e sessões mão na massa 20 ou 30 minutos.')
      end
    end

    it 'generates hint from session types in english' do
      I18n.with_locale('en') do
        hint = helper.duration_mins_hint([
          FactoryGirl.build(:session_type, title: 'session_types.workshop.title', valid_durations: [20]),
          FactoryGirl.build(:session_type, title: 'session_types.hands_on.title', valid_durations: [40])
        ])
        expect(hint).to eq('Workshops should last 20 minutes and hands on sessions 40 minutes.')
      end
    end
  end

  describe '#options_for_session_types' do
    let!(:type) { FactoryGirl.create :session_type, title: 'session_types.talk.title' }
    let!(:other_type) { FactoryGirl.create :session_type, title: 'session_types.talk.title' }
    let(:type_array) { [other_type, type] }

    subject { helper.options_for_session_types(type_array) }
    it { is_expected.to eq [['Palestra', other_type.id], ['Palestra', type.id]] }
  end
end

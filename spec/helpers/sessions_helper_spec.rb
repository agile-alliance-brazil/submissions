# encoding: UTF-8
# frozen_string_literal: true

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
                                               FactoryGirl.build(:session_type, valid_durations: [30, 40])
                                             ])
        expect(durations).to eq([10, 20, 30, 40])
      end

      it 'removes duplicates' do
        durations = helper.all_durations_for([
                                               FactoryGirl.build(:session_type, valid_durations: [10, 20]),
                                               FactoryGirl.build(:session_type, valid_durations: [20, 30])
                                             ])
        expect(durations).to eq([10, 20, 30])
      end

      it 'sorts durations' do
        durations = helper.all_durations_for([
                                               FactoryGirl.build(:session_type, valid_durations: [20, 40]),
                                               FactoryGirl.build(:session_type, valid_durations: [30, 10])
                                             ])
        expect(durations).to eq([10, 20, 30, 40])
      end
    end
  end

  describe '#options_for_durations' do
    it 'returns human readable collection of durations' do
      options = helper.options_for_durations([
                                               FactoryGirl.build(:session_type, valid_durations: [20, 40]),
                                               FactoryGirl.build(:session_type, valid_durations: [10, 20])
                                             ])
      expect(options).to eq([["10 #{t('generic.minutes')}", 10], ["20 #{t('generic.minutes')}", 20], ["40 #{t('generic.minutes')}", 40]])
    end
  end

  describe '#durations_to_hide' do
    it 'returns durations to hide as strings' do
      session_type1 = FactoryGirl.create(:session_type, valid_durations: [20, 40])
      session_type2 = FactoryGirl.create(:session_type, valid_durations: [10, 20])
      durations_to_hide = helper.durations_to_hide([session_type1, session_type2])
      expect(durations_to_hide[session_type1.id]).to eq(['10'])
      expect(durations_to_hide[session_type2.id]).to eq(['40'])
    end

    it 'hides default option when session type only accepts a single duration' do
      session_type1 = FactoryGirl.create(:session_type, valid_durations: [40])
      session_type2 = FactoryGirl.create(:session_type, valid_durations: [10, 20])
      durations_to_hide = helper.durations_to_hide([session_type1, session_type2])
      expect(durations_to_hide[session_type1.id]).to eq(['10', '20', ''])
      expect(durations_to_hide[session_type2.id]).to eq(['40'])
    end
  end

  context 'type titles with language set' do
    let(:conference) { FactoryGirl.build :conference, supported_languages: ['en', 'pt-BR'] }
    let(:palestra) { FactoryGirl.build :translated_content, language: 'pt-BR', title: 'Palestra' }

    describe '#duration_mins_hint' do
      let(:relato) { FactoryGirl.build :translated_content, language: 'pt-BR', title: 'Relato de Experiência' }
      let(:na_massa) { FactoryGirl.build :translated_content, language: 'pt-BR', title: 'Mão na massa' }
      let(:workshop) { FactoryGirl.build :translated_content, language: 'en', title: 'Workshop' }
      let(:hands_on) { FactoryGirl.build :translated_content, language: 'en', title: 'Hands on' }

      it 'generates hint from session types in portuguese' do
        I18n.with_locale('pt-BR') do
          hint = helper.duration_mins_hint([
                                             FactoryGirl.build(:session_type, conference: conference, translated_contents: [palestra], valid_durations: [20, 40]),
                                             FactoryGirl.build(:session_type, conference: conference, translated_contents: [relato], valid_durations: [10]),
                                             FactoryGirl.build(:session_type, conference: conference, translated_contents: [na_massa], valid_durations: [30, 20])
                                           ])
          expect(hint).to eq('Palestra deve ter duração de 20 ou 40 minutos, relato de experiência 10 minutos e mão na massa 20 ou 30 minutos.')
        end
      end

      it 'generates hint from session types in english' do
        I18n.with_locale('en') do
          hint = helper.duration_mins_hint([
                                             FactoryGirl.build(:session_type, conference: conference, translated_contents: [workshop], valid_durations: [20]),
                                             FactoryGirl.build(:session_type, conference: conference, translated_contents: [hands_on], valid_durations: [40])
                                           ])
          expect(hint).to eq('Workshop should last 20 minutes and hands on 40 minutes.')
        end
      end
    end

    describe '#options_for_session_types' do
      let!(:type) { FactoryGirl.build :session_type, conference: conference, translated_contents: [palestra] }
      let!(:other_type) { FactoryGirl.build :session_type, conference: conference, translated_contents: [palestra.clone] }
      let(:type_array) { [other_type, type] }

      subject { helper.options_for_session_types(type_array) }
      it { I18n.with_locale('pt-BR') { is_expected.to eq [['Palestra', other_type.id], ['Palestra', type.id]] } }
    end
  end
end

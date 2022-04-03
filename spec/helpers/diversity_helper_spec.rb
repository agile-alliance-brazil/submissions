# frozen_string_literal: true

require 'spec_helper'

describe DiversityHelper, type: :helper do
  describe '#gender_options' do
    let(:values) { helper.gender_options.map(&:last) }
    let(:texts) { helper.gender_options.map(&:first) }

    it { expect(helper.gender_options).to all(have(2).items) }
    it { expect(values).to eq(%i[rather_not_answer cis_man trans_man cis_woman trans_woman non_binary i_dont_know]) }
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(texts).to eq(['Prefiro não informar', 'Homem cisgênero', 'Homem transgênero', 'Mulher cisgênera', 'Mulher transgênera', 'Pessoa de gênero não-binário', 'Não sei responder']) }
      end
    end
  end

  describe '#transalte_gender' do
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(helper.translated_gender(:cis_man)).to eq('Homem cisgênero') }
        it { expect(helper.translated_gender('cis_man')).to eq('Homem cisgênero') }
        it { expect(helper.translated_gender(:trans_man)).to eq('Homem transgênero') }
        it { expect(helper.translated_gender('trans_man')).to eq('Homem transgênero') }
        it { expect(helper.translated_gender(:cis_woman)).to eq('Mulher cisgênera') }
        it { expect(helper.translated_gender('cis_woman')).to eq('Mulher cisgênera') }
        it { expect(helper.translated_gender(:trans_woman)).to eq('Mulher transgênera') }
        it { expect(helper.translated_gender('trans_woman')).to eq('Mulher transgênera') }
        it { expect(helper.translated_gender(:non_binary)).to eq('Pessoa de gênero não-binário') }
        it { expect(helper.translated_gender('non_binary')).to eq('Pessoa de gênero não-binário') }
        it { expect(helper.translated_gender(:rather_not_answer)).to eq('Prefiro não informar') }
        it { expect(helper.translated_gender('rather_not_answer')).to eq('Prefiro não informar') }
        it { expect(helper.translated_gender(:i_dont_know)).to eq('Não sei responder') }
        it { expect(helper.translated_gender('i_dont_know')).to eq('Não sei responder') }
      end
    end

    context 'when invalid argument' do
      it { expect(helper.translated_gender('')).to be_empty }
      it { expect(helper.translated_gender(nil)).to be_empty }
      it { expect(helper.translated_gender(' ')).to be_empty }
      it { expect(helper.translated_gender('SS')).to be_empty }
    end
  end

  describe '#race_options' do
    let(:values) { helper.race_options.map(&:last) }
    let(:texts) { helper.race_options.map(&:first) }

    it { expect(helper.race_options).to all(have(2).items) }
    it { expect(values).to eq(%i[rather_not_answer yellow white indian brown black i_dont_know]) }
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(texts).to eq(['Prefiro não informar', 'Amarela', 'Branca', 'Indígena', 'Parda', 'Preta', 'Não sei responder']) }
      end
    end
  end

  describe '#transalte_race' do
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(helper.translated_race(:yellow)).to eq('Amarela') }
        it { expect(helper.translated_race('yellow')).to eq('Amarela') }
        it { expect(helper.translated_race(:white)).to eq('Branca') }
        it { expect(helper.translated_race('white')).to eq('Branca') }
        it { expect(helper.translated_race(:indian)).to eq('Indígena') }
        it { expect(helper.translated_race('indian')).to eq('Indígena') }
        it { expect(helper.translated_race(:brown)).to eq('Parda') }
        it { expect(helper.translated_race('brown')).to eq('Parda') }
        it { expect(helper.translated_race(:black)).to eq('Preta') }
        it { expect(helper.translated_race('black')).to eq('Preta') }
        it { expect(helper.translated_race(:rather_not_answer)).to eq('Prefiro não informar') }
        it { expect(helper.translated_race('rather_not_answer')).to eq('Prefiro não informar') }
        it { expect(helper.translated_race(:i_dont_know)).to eq('Não sei responder') }
        it { expect(helper.translated_race('i_dont_know')).to eq('Não sei responder') }
      end
    end

    context 'when invalid argument' do
      it { expect(helper.translated_race('')).to be_empty }
      it { expect(helper.translated_race(nil)).to be_empty }
      it { expect(helper.translated_race(' ')).to be_empty }
      it { expect(helper.translated_race('SS')).to be_empty }
    end
  end
end

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

  describe '#disability_options' do
    let(:values) { helper.disability_options.map(&:last) }
    let(:texts) { helper.disability_options.map(&:first) }

    it { expect(helper.disability_options).to all(have(2).items) }
    it { expect(values).to eq(%i[rather_not_answer no_disability visual hearing physical_or_motor mental_or_intellectual i_dont_know]) }
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(texts).to eq(['Prefiro não informar', 'Não tenho deficiência', 'Sim, deficiência visual', 'Sim, deficiência auditiva', 'Sim, deficiência física ou motora', 'Sim, deficiência mental ou intelectual', 'Não sei responder']) }
      end
    end
  end

  describe '#transalte_disability' do
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(helper.translated_disability(:no_disability)).to eq('Não tenho deficiência') }
        it { expect(helper.translated_disability('no_disability')).to eq('Não tenho deficiência') }
        it { expect(helper.translated_disability(:visual)).to eq('Sim, deficiência visual') }
        it { expect(helper.translated_disability('visual')).to eq('Sim, deficiência visual') }
        it { expect(helper.translated_disability(:hearing)).to eq('Sim, deficiência auditiva') }
        it { expect(helper.translated_disability('hearing')).to eq('Sim, deficiência auditiva') }
        it { expect(helper.translated_disability(:physical_or_motor)).to eq('Sim, deficiência física ou motora') }
        it { expect(helper.translated_disability('physical_or_motor')).to eq('Sim, deficiência física ou motora') }
        it { expect(helper.translated_disability(:mental_or_intellectual)).to eq('Sim, deficiência mental ou intelectual') }
        it { expect(helper.translated_disability('mental_or_intellectual')).to eq('Sim, deficiência mental ou intelectual') }
        it { expect(helper.translated_disability(:rather_not_answer)).to eq('Prefiro não informar') }
        it { expect(helper.translated_disability('rather_not_answer')).to eq('Prefiro não informar') }
        it { expect(helper.translated_disability(:i_dont_know)).to eq('Não sei responder') }
        it { expect(helper.translated_disability('i_dont_know')).to eq('Não sei responder') }
      end
    end

    context 'when invalid argument' do
      it { expect(helper.translated_disability('')).to be_empty }
      it { expect(helper.translated_disability(nil)).to be_empty }
      it { expect(helper.translated_disability(' ')).to be_empty }
      it { expect(helper.translated_disability('SS')).to be_empty }
    end
  end

  describe '#translated_age_range' do
    context 'when pt-BR locale' do
      it { expect(helper.translated_age_range(DateTime.current)).to eq('Até 18 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -18))).to eq('Até 18 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -18, days: -364))).to eq('Até 18 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -19))).to eq('19 a 24 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -24))).to eq('19 a 24 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -25))).to eq('25 a 29 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -29))).to eq('25 a 29 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -30))).to eq('30 a 34 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -34))).to eq('30 a 34 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -35))).to eq('35 a 39 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -39))).to eq('35 a 39 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -40))).to eq('40 a 44 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -44))).to eq('40 a 44 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -45))).to eq('45 a 49 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -49))).to eq('45 a 49 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -50))).to eq('50 a 54 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -54))).to eq('50 a 54 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -55))).to eq('55 a 59 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -59))).to eq('55 a 59 anos') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -60))).to eq('60 anos ou mais') }

      it { expect(helper.translated_age_range('invalid')).to eq('') }
    end
  end

  describe '#is_parent_options' do
    let(:values) { helper.is_parent_options.map(&:last) }
    let(:texts) { helper.is_parent_options.map(&:first) }

    it { expect(helper.is_parent_options).to all(have(2).items) }
    it { expect(values).to eq(%i[rather_not_answer yes no]) }
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(texts).to eq(['Prefiro não informar', 'Sim', 'Não']) }
      end
    end
  end

  describe '#translated_is_parent' do
    context 'when pt-BR locale' do
      I18n.with_locale('pt-BR') do
        it { expect(helper.translated_is_parent(:yes)).to eq('Sim') }
        it { expect(helper.translated_is_parent('yes')).to eq('Sim') }
        it { expect(helper.translated_is_parent(:no)).to eq('Não') }
        it { expect(helper.translated_is_parent('no')).to eq('Não') }
      end
    end

    context 'when invalid argument' do
      it { expect(helper.translated_is_parent('')).to be_empty }
      it { expect(helper.translated_is_parent(nil)).to be_empty }
      it { expect(helper.translated_is_parent(' ')).to be_empty }
      it { expect(helper.translated_is_parent('SS')).to be_empty }
    end
  end
end

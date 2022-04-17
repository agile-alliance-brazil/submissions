# frozen_string_literal: true

require 'spec_helper'

describe DiversityHelper, type: :helper do
  before :all do
    @locale = I18n.locale
  end

  after :all do
    I18n.locale = @locale
  end

  describe '#gender_options' do
    let(:values) { helper.gender_options.map(&:last) }
    let(:texts) { helper.gender_options.map(&:first) }

    it { expect(helper.gender_options).to all(have(2).items) }
    it { expect(values).to eq(%i[cis_man trans_man cis_woman trans_woman transvestite i_dont_know non_binary rather_not_answer]) }

    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(texts).to eq(['Homem cisgênero', 'Homem transgênero', 'Mulher cisgênera', 'Mulher transgênera', 'Travesti', 'Não sei responder', 'Pessoa de gênero não-binário', 'Prefiro não informar']) }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(texts).to eq(['Cisgender man', 'Transgender man', 'Cisgender woman', 'Transgender woman', 'Transvestite', "I don't know", 'Non binary gender person', 'Rather not answer']) }
    end
  end

  describe '#transalte_gender' do
    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(helper.translated_gender(:cis_man)).to eq('Homem cisgênero') }
      it { expect(helper.translated_gender('trans_man')).to eq('Homem transgênero') }
      it { expect(helper.translated_gender(:cis_woman)).to eq('Mulher cisgênera') }
      it { expect(helper.translated_gender('trans_woman')).to eq('Mulher transgênera') }
      it { expect(helper.translated_gender(:non_binary)).to eq('Pessoa de gênero não-binário') }
      it { expect(helper.translated_gender('i_dont_know')).to eq('Não sei responder') }
      it { expect(helper.translated_gender(:rather_not_answer)).to eq('Prefiro não informar') }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_gender('cis_man')).to eq('Cisgender man') }
      it { expect(helper.translated_gender(:trans_man)).to eq('Transgender man') }
      it { expect(helper.translated_gender('cis_woman')).to eq('Cisgender woman') }
      it { expect(helper.translated_gender(:trans_woman)).to eq('Transgender woman') }
      it { expect(helper.translated_gender('non_binary')).to eq('Non binary gender person') }
      it { expect(helper.translated_gender(:i_dont_know)).to eq("I don't know") }
      it { expect(helper.translated_gender('rather_not_answer')).to eq('Rather not answer') }
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
    it { expect(values).to eq(%i[asian white indigenous brown black i_dont_know rather_not_answer]) }

    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(texts).to eq(['Pessoa asiática', 'Pessoa branca', 'Pessoa indígena', 'Pessoa parda', 'Pessoa preta', 'Não sei', 'Prefiro não informar']) }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(texts).to eq(['Asian person', 'White person', 'Indigenous person', 'Brown person', 'Black person', "I don't know", 'Rather not answer']) }
    end
  end

  describe '#transalte_race' do
    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(helper.translated_race(:asian)).to eq('Pessoa asiática') }
      it { expect(helper.translated_race('white')).to eq('Pessoa branca') }
      it { expect(helper.translated_race(:indigenous)).to eq('Pessoa indígena') }
      it { expect(helper.translated_race('brown')).to eq('Pessoa parda') }
      it { expect(helper.translated_race(:black)).to eq('Pessoa preta') }
      it { expect(helper.translated_race('i_dont_know')).to eq('Não sei') }
      it { expect(helper.translated_race(:rather_not_answer)).to eq('Prefiro não informar') }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_race('asian')).to eq('Asian person') }
      it { expect(helper.translated_race(:white)).to eq('White person') }
      it { expect(helper.translated_race('indigenous')).to eq('Indigenous person') }
      it { expect(helper.translated_race(:brown)).to eq('Brown person') }
      it { expect(helper.translated_race('black')).to eq('Black person') }
      it { expect(helper.translated_race(:i_dont_know)).to eq("I don't know") }
      it { expect(helper.translated_race('rather_not_answer')).to eq('Rather not answer') }
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
    it { expect(values).to eq(%i[no_disability visual hearing physical_or_motor mental_or_intellectual deafblindness multiple_disability rather_not_answer]) }

    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(texts).to eq(['Não tenho deficiência', 'Sim, deficiência visual', 'Sim, deficiência auditiva', 'Sim, deficiência física ou motora', 'Sim, deficiência mental ou intelectual', 'Sim, surdocegueira', 'Sim, deficiência múltipla', 'Prefiro não informar']) }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(texts).to eq(["I don't have any disability", 'Yes, visual disability', 'Yes, hearing disability', 'Yes, physic or motor disability', 'Yes, mental or intellectual disability', 'Yes, deafblindness', 'Yes, multiple disability', 'Rather not answer']) }
    end
  end

  describe '#transalte_disability' do
    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(helper.translated_disability(:no_disability)).to eq('Não tenho deficiência') }
      it { expect(helper.translated_disability('visual')).to eq('Sim, deficiência visual') }
      it { expect(helper.translated_disability(:hearing)).to eq('Sim, deficiência auditiva') }
      it { expect(helper.translated_disability('physical_or_motor')).to eq('Sim, deficiência física ou motora') }
      it { expect(helper.translated_disability(:mental_or_intellectual)).to eq('Sim, deficiência mental ou intelectual') }
      it { expect(helper.translated_disability('deafblindness')).to eq('Sim, surdocegueira') }
      it { expect(helper.translated_disability(:multiple_disability)).to eq('Sim, deficiência múltipla') }
      it { expect(helper.translated_disability('rather_not_answer')).to eq('Prefiro não informar') }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_disability('no_disability')).to eq("I don't have any disability") }
      it { expect(helper.translated_disability(:visual)).to eq('Yes, visual disability') }
      it { expect(helper.translated_disability('hearing')).to eq('Yes, hearing disability') }
      it { expect(helper.translated_disability(:physical_or_motor)).to eq('Yes, physic or motor disability') }
      it { expect(helper.translated_disability('mental_or_intellectual')).to eq('Yes, mental or intellectual disability') }
      it { expect(helper.translated_disability(:deafblindness)).to eq('Yes, deafblindness') }
      it { expect(helper.translated_disability('multiple_disability')).to eq('Yes, multiple disability') }
      it { expect(helper.translated_disability(:rather_not_answer)).to eq('Rather not answer') }
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
      before :all do
        I18n.locale = :'pt-BR'
      end

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
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_age_range(DateTime.current)).to eq('Until 18 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -18))).to eq('Until 18 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -18, days: -364))).to eq('Until 18 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -19))).to eq('19 to 24 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -24))).to eq('19 to 24 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -25))).to eq('25 to 29 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -29))).to eq('25 to 29 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -30))).to eq('30 to 34 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -34))).to eq('30 to 34 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -35))).to eq('35 to 39 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -39))).to eq('35 to 39 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -40))).to eq('40 to 44 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -44))).to eq('40 to 44 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -45))).to eq('45 to 49 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -49))).to eq('45 to 49 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -50))).to eq('50 to 54 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -54))).to eq('50 to 54 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -55))).to eq('55 to 59 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -59))).to eq('55 to 59 years old') }
      it { expect(helper.translated_age_range(DateTime.current.advance(years: -60))).to eq('60 years old or above') }
    end

    context 'when invalid input' do
      it { expect(helper.translated_age_range('')).to be_empty }
      it { expect(helper.translated_age_range(nil)).to be_empty }
      it { expect(helper.translated_age_range(' ')).to be_empty }
      it { expect(helper.translated_age_range('SS')).to be_empty }
    end
  end

  describe '#is_parent_options' do
    let(:values) { helper.is_parent_options.map(&:last) }
    let(:texts) { helper.is_parent_options.map(&:first) }

    it { expect(helper.is_parent_options).to all(have(2).items) }
    it { expect(values).to eq(%i[yes no rather_not_answer]) }

    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(texts).to eq(['Sim', 'Não', 'Prefiro não informar']) }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(texts).to eq(['Yes', 'No', 'Rather not answer']) }
    end
  end

  describe '#translated_is_parent' do
    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(helper.translated_is_parent(:yes)).to eq('Sim') }
      it { expect(helper.translated_is_parent('no')).to eq('Não') }
      it { expect(helper.translated_is_parent(:rather_not_answer)).to eq('Prefiro não informar') }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_is_parent('yes')).to eq('Yes') }
      it { expect(helper.translated_is_parent(:no)).to eq('No') }
      it { expect(helper.translated_is_parent('rather_not_answer')).to eq('Rather not answer') }
    end

    context 'when invalid argument' do
      it { expect(helper.translated_is_parent('')).to be_empty }
      it { expect(helper.translated_is_parent(nil)).to be_empty }
      it { expect(helper.translated_is_parent(' ')).to be_empty }
      it { expect(helper.translated_is_parent('SS')).to be_empty }
    end
  end

  describe '#home_geographical_area_options' do
    let(:values) { helper.home_geographical_area_options.map(&:last) }
    let(:texts) { helper.home_geographical_area_options.map(&:first) }

    it { expect(helper.home_geographical_area_options).to all(have(2).items) }
    it { expect(values).to eq(%i[metropolitan periferic rural indigenous quilombola riverside rather_not_answer]) }

    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(texts).to eq(['Zona urbana central/metropolitana', 'Zona urbana periférica', 'Zona Rural', 'Comunidade indígena', 'Comunidade quilombola', 'Comunidade ribeirinha', 'Prefiro não informar']) }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(texts).to eq(['Urban central/metropolitan area', 'Peripheral area', 'Rural area', 'Indigenous community', 'Quilombola community', 'Riverside community', 'Rather not answer']) }
    end
  end

  describe '#translated_home_geographical_area' do
    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(helper.translated_home_geographical_area(:metropolitan)).to eq('Zona urbana central/metropolitana') }
      it { expect(helper.translated_home_geographical_area('periferic')).to eq('Zona urbana periférica') }
      it { expect(helper.translated_home_geographical_area(:rural)).to eq('Zona Rural') }
      it { expect(helper.translated_home_geographical_area('indigenous')).to eq('Comunidade indígena') }
      it { expect(helper.translated_home_geographical_area(:quilombola)).to eq('Comunidade quilombola') }
      it { expect(helper.translated_home_geographical_area('riverside')).to eq('Comunidade ribeirinha') }
      it { expect(helper.translated_home_geographical_area(:rather_not_answer)).to eq('Prefiro não informar') }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_home_geographical_area('metropolitan')).to eq('Urban central/metropolitan area') }
      it { expect(helper.translated_home_geographical_area(:periferic)).to eq('Peripheral area') }
      it { expect(helper.translated_home_geographical_area('rural')).to eq('Rural area') }
      it { expect(helper.translated_home_geographical_area(:indigenous)).to eq('Indigenous community') }
      it { expect(helper.translated_home_geographical_area('quilombola')).to eq('Quilombola community') }
      it { expect(helper.translated_home_geographical_area(:riverside)).to eq('Riverside community') }
      it { expect(helper.translated_home_geographical_area('rather_not_answer')).to eq('Rather not answer') }
    end

    context 'when invalid argument' do
      it { expect(helper.translated_home_geographical_area('')).to be_empty }
      it { expect(helper.translated_home_geographical_area(nil)).to be_empty }
      it { expect(helper.translated_home_geographical_area(' ')).to be_empty }
      it { expect(helper.translated_home_geographical_area('SS')).to be_empty }
    end
  end

  describe '#agility_experience_options' do
    let(:values) { helper.agility_experience_options.map(&:last) }
    let(:texts) { helper.agility_experience_options.map(&:first) }

    it { expect(helper.agility_experience_options).to all(have(2).items) }
    it { expect(values).to eq(%i[until_1 1_to_2 2_to_3 3_to_4 more_than_4 no_but_transitioning no]) }

    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(texts).to eq(['Sim, até 1 ano', 'Sim, de 1 até 2 anos', 'Sim, de 2 até 3 anos', 'Sim, de 3 até 4 anos', 'Sim, mais que 4 anos', 'Não, mas estou em busca de transição de carreira', 'Não']) }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(texts).to eq(['Yes, until 1 year', 'Yes, between 1 and 2 years', 'Yes, between 2 and 3 years', 'Yes, between 3 and 4 years', 'Yes, more than 4 years', 'No, but I want transitate to it', 'No']) }
    end
  end

  describe '#translated_agility_experience' do
    context 'when pt-BR locale' do
      before :all do
        I18n.locale = :'pt-BR'
      end

      it { expect(helper.translated_agility_experience(:until_1)).to eq('Sim, até 1 ano') }
      it { expect(helper.translated_agility_experience('1_to_2')).to eq('Sim, de 1 até 2 anos') }
      it { expect(helper.translated_agility_experience(:'2_to_3')).to eq('Sim, de 2 até 3 anos') }
      it { expect(helper.translated_agility_experience('3_to_4')).to eq('Sim, de 3 até 4 anos') }
      it { expect(helper.translated_agility_experience(:more_than_4)).to eq('Sim, mais que 4 anos') }
      it { expect(helper.translated_agility_experience('no_but_transitioning')).to eq('Não, mas estou em busca de transição de carreira') }
      it { expect(helper.translated_agility_experience(:no)).to eq('Não') }
    end

    context 'when en locale' do
      before :all do
        I18n.locale = :en
      end

      it { expect(helper.translated_agility_experience('until_1')).to eq('Yes, until 1 year') }
      it { expect(helper.translated_agility_experience(:'1_to_2')).to eq('Yes, between 1 and 2 years') }
      it { expect(helper.translated_agility_experience('2_to_3')).to eq('Yes, between 2 and 3 years') }
      it { expect(helper.translated_agility_experience(:'3_to_4')).to eq('Yes, between 3 and 4 years') }
      it { expect(helper.translated_agility_experience('more_than_4')).to eq('Yes, more than 4 years') }
      it { expect(helper.translated_agility_experience(:no_but_transitioning)).to eq('No, but I want transitate to it') }
      it { expect(helper.translated_agility_experience('no')).to eq('No') }
    end

    context 'when invalid argument' do
      it { expect(helper.translated_agility_experience('')).to be_empty }
      it { expect(helper.translated_agility_experience(nil)).to be_empty }
      it { expect(helper.translated_agility_experience(' ')).to be_empty }
      it { expect(helper.translated_agility_experience('SS')).to be_empty }
    end
  end
end

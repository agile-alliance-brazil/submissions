# frozen_string_literal: true

module ValidatesExistenceMacros
  extend ActiveSupport::Concern

  module ClassMethods
    def should_validate_existence_of(*associations)
      allow_nil = associations.extract_options![:allow_blank]

      if allow_nil
        associations.each do |association|
          it "requires #{association} to exist, allowing blank" do
            reflection = subject.class.reflect_on_association(association)
            object = subject
            object.send("#{association}=", nil)
            object.valid?
            expect(object.errors[reflection.foreign_key.to_sym]).not_to include(I18n.t('activerecord.errors.messages.existence'))
          end
        end
      end

      associations.each do |association|
        it "requires #{association} to exist" do
          reflection = subject.class.reflect_on_association(association)
          object = subject
          object.send("#{reflection.foreign_key}=", 0)
          expect(object).not_to be_valid
          expect(object.errors[reflection.foreign_key.to_sym]).to include(I18n.t('activerecord.errors.messages.existence'))
        end
      end
    end
  end
end

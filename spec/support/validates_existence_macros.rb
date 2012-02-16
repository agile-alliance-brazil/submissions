# encoding: UTF-8
module ValidatesExistenceMacros
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def should_validate_existence_of(*associations)
      allow_nil = associations.extract_options![:allow_nil]

      if allow_nil
        associations.each do |association|
          it "allows #{association} to be nil" do
            reflection = subject.class.reflect_on_association(association)
            object = subject
            object.send("#{association}=", nil)
            object.valid?
            object.errors[reflection.foreign_key.to_sym].should_not include(I18n.t("activerecord.errors.messages.existence"))
          end
        end
      else
        associations.each do |association|
          it "requires #{association} exists" do
            reflection = subject.class.reflect_on_association(association)
            object = subject
            object.send("#{association}=", nil)
            object.should_not be_valid
            object.errors[reflection.foreign_key.to_sym].should include(I18n.t("activerecord.errors.messages.existence"))
          end
        end
      end
    end
  end
end

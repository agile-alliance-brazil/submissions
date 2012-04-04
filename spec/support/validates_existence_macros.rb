# encoding: UTF-8
module ValidatesExistenceMacros
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def should_validate_existence_of(*associations)
      allow_nil = associations.extract_options![:allow_blank]

      if allow_nil
        associations.each do |association|
          it "reqiores #{association} to exist, allowing blank" do
            reflection = subject.class.reflect_on_association(association)
            object = subject
            object.send("#{association}=", nil)
            object.valid?
            object.errors[reflection.foreign_key.to_sym].should_not include(I18n.t("activerecord.errors.messages.existence"))
            object.send("build_#{association}")
            object.valid?
            object.errors[reflection.foreign_key.to_sym].should_not include(I18n.t("activerecord.errors.messages.existence"))
          end
        end
      else
        associations.each do |association|
          it "requires #{association} to exist" do
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

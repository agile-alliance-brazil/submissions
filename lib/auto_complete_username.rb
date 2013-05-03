#encoding: utf-8
module AutoCompleteUsername
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_autocomplete_username_as(user_attr)
      attribute_name = :"#{user_attr}_username"
      # def second_author_username
      #   @second_author_username || second_author.try(:username)
      # end
      define_method(attribute_name) do
        instance_variable_get(:"@#{attribute_name}") || send(user_attr.to_sym).try(:username)
      end

      # def second_author_username=(username)
      #   @second_author_username = username.try(:strip)
      #   self.second_author = @second_author_username.present? ? User.find_by_username(@second_author_username) : nil
      #   @second_author_username
      # end
      define_method(:"#{attribute_name}=") do |username|
        username = username.try(:strip)
        instance_variable_set(:"@#{attribute_name}", username)
        send(:"#{user_attr}=", (username.present? ? User.find_by_username(username) : nil))
        username
      end

      # transfer errors to virtual attribute
      after_validation do
        if !errors[:"#{user_attr}_id"].empty?
          errors[:"#{user_attr}_id"].each { |error| errors.add(attribute_name, error) }
        end
        if !errors[user_attr.to_sym].empty?
          errors[user_attr.to_sym].each { |error| errors.add(attribute_name, error) }
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, AutoCompleteUsername)
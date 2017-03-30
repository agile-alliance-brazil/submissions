# encoding: UTF-8
# frozen_string_literal: true

# This module is included in your user model which makes
# several methods available to handle roles for authorization.
# The can-can gem is being used for implementing the authorization rules
module Authorization
  ROLES = %w(admin author reviewer organizer voter).freeze

  def roles=(roles)
    self.roles_mask = ([*roles].map(&:to_s) & ROLES).map { |r| role_index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & role_index(r)).zero? }
  end

  def add_role(role)
    self.roles_mask = (roles_mask || 0) | role_index(role.to_s)
  end

  def remove_role(role)
    self.roles_mask = (roles_mask || 0) & ~role_index(role.to_s)
  end

  def self.included(model)
    ROLES.each do |role|
      model.send :define_method, "#{role}?" do
        ((roles_mask || 0) & role_index(role)) != 0
      end
    end
  end

  def guest?
    (roles_mask || 0).zero?
  end

  private

  def role_index(role)
    2**ROLES.index(role)
  rescue
    0
  end
end

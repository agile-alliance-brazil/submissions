# encoding: UTF-8
require 'privileges/base'
require 'privileges/admin'
require 'privileges/author'
require 'privileges/guest'
require 'privileges/organizer'
require 'privileges/reviewer'
require 'privileges/voter'

class Ability
  include CanCan::Ability

  attr_reader :user, :conference, :session, :reviewer

  def initialize(user, conference, session=nil, reviewer=nil)
    @user = user || User.new # guest
    @conference, @session, @reviewer = conference, session, reviewer

    Privileges::Guest.new(self).privileges
    Authorization::ROLES.each do |role|
      Privileges.const_get(role.to_s.classify).new(self).privileges if @user.send(:"#{role}?")
    end
  end

end

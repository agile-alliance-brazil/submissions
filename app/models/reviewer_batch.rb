# encoding: UTF-8
class ReviewerBatch
  include ActiveModel::Model

  attr_accessor :conference, :usernames
  attr_reader :valid, :invalid

  def initialize(attributes={})
    super
    prepare_reviewers
  end

  def save
    prepare_reviewers
    @valid.each(&:save!)
    self
  end

  def to_json
    hash = {
      new_reviewers: @valid.map {|r| ReviewerJsonBuilder.new(r).to_json },
      failed_invites: @invalid.map {|r| I18n.t('flash.reviewer.create.failure', username: r.user_username)}
    }
    hash[:success_message]= I18n.t('flash.reviewer.create.multiple_successes') unless @valid.empty?
    hash
  end

  private

  def prepare_reviewers
    @valid, @invalid = (usernames || []).
      map {|u| Reviewer.new(user_username: u, conference: conference) }.
      partition(&:valid?)
  end
end
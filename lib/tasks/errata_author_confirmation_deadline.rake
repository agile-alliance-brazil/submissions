# frozen_string_literal: true

namespace :publish do
  desc 'Publish errata of session reviews and decisions for accepted sessions'
  task author_confirmation_deadline_errata: [:environment] do
    ErrataAuthorConfirmationDeadline.new.publish
  end
end

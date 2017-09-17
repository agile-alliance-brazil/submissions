# frozen_string_literal: true

Dir.glob(Rails.root.join('lib', '*_extensions', '**', '*.rb')) do |file|
  require file
end

# frozen_string_literal: true

Dir.glob(Rails.root.join('lib', '*_extensions', '**', '*.rb')).sort.each do |file|
  require file
end

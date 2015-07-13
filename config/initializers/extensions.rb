# encoding: UTF-8
Dir.glob("#{Rails.root}/lib/*_extensions/**/*.rb") do |file|
  require file
end

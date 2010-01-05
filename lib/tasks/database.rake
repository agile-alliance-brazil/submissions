Rake::Task["db:migrate"].enhance do
  Rake::Task["db:seed_fu"].invoke
end

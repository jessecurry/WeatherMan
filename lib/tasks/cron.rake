desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  # Pull Weather Stations
  Rake::Task['noaa:pull_wx_stations'].invoke
end



namespace :noaa  do
  desc "Pull Weather Station Definitions from NOAA"
  task :pull_wx_stations => :environment do
    puts 'Preparing to pull wx_stations from NOAA.'
    
    # Create a Hydra to handle our requests
    hydra = Typhoeus::Hydra.new
    
    # Build the request object
    request = Typhoeus::Request.new("http://www.weather.gov/xml/current_obs/index.xml", :method => :get)
    
    # Setup the completion handler                                
    request.on_complete do |response|
      if response.success?
        ws = REXML::Document.new(response.body)
        ws.elements.each('wx_station_index/station') do |station|
          identifier = station.elements['station_id'].text
          
          # Create the Weather Station Object
          wx = WeatherStation.find_or_create_by_identifier(identifier)
          if wx
            wx.state = station.elements['state'].text
            wx.name = station.elements['station_name'].text
            wx.latitude = station.elements['latitude'].text
            wx.longitude = station.elements['longitude'].text
            wx.html_url = station.elements['html_url'].text
            wx.rss_url = station.elements['rss_url'].text
            wx.xml_url = station.elements['xml_url'].text
            
            # Attempt to save
            puts('Error saving: ' + identifier) if !wx.save
          end
        end
      elsif response.timed_out?
        puts 'HTTP Request Timed Out'
      elsif response.code == 0
        puts 'HTTP Request Failed: ' + response.curl_error_message
      else
        puts 'HTTP Request Failed: ' + response.code.to_s
      end
    end
    
    # Queue, then run the request
    hydra.queue request
    hydra.run
    
    puts 'noaa:pull_wx_stations completed'
  end
  
  private
  
end
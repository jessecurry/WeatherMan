class WeatherController < ApplicationController

  
  # GET /current_conditions?lat=XX&lon=XX
  def current_conditions
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    weather_station = WeatherStation.near([lat, lon], 10).all.first
    
    # Pull current conditions as hash
    current_conditions = {}
    if weather_station.nil?
      current_conditions = {:error => "No station found near #{lat}, #{lon}"}
    else
      current_conditions = pull_current_conditions weather_station.xml_url
    end

    #
    render :json => current_conditions # weather_station
  end
  
  ###############################################
  private
  
  def pull_current_conditions xml_url
    logger.debug 'Fetching: ' + xml_url
    
    # Default return
    conditions = {:error => 'Unable to fetch current conditions.'} 
      
    # Create a Hydra to handle our requests
    hydra = Typhoeus::Hydra.new
    
    # Build the request object
    request = Typhoeus::Request.new(xml_url, 
                                    :method => :get, 
                                    :follow_location => true)
    
    # Setup the completion handler                                
    request.on_complete do |response|
      if response.success?
        REXML::Document.new(response.body)
        conditions = Hash.from_xml(response.body)
        conditions = conditions['current_observation'] if conditions
      elsif response.timed_out?
        logger.error 'HTTP Request Timed Out'
      elsif response.code == 0
        logger.error 'HTTP Request Failed: ' + response.curl_error_message
      else
        logger.error 'HTTP Request Failed: ' + response.code.to_s
      end
    end
    
    # Queue, then run the request
    hydra.queue request
    hydra.run

    conditions # return the weather conditions
  end
  
end

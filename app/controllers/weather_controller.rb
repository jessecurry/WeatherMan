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
  
  # Forecase
  def forecast
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    begin_date = params[:begin]
    end_date = params[:end]
    
    # Pull forecast as hash
    forecast = pull_forecast lat, lon, begin_date, end_date

    #
    render :json => forecast # weather_station
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
  
  ###############################################
  # Forecast
  def pull_forecast lat, lon, begin_date = DateTime.now, end_date=DateTime.now
    logger.debug "Fetching forecast: #{lat}, #{lon}"
    
    build_url = "http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgen&lat=#{lat}&lon=#{lon}&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&listLat1=&listLon1=&listLat2=&listLon2=&resolutionList=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&listEndPoint1Lat=&listEndPoint1Lon=&listEndPoint2Lat=&listEndPoint2Lon=&zipCodeList=&listZipCodeList=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&listCenterPointLat=&listCenterPointLon=&listDistanceLat=&listDistanceLon=&listResolutionSquare=&citiesLevel=&listCitiesLevel=&sector=&gmlListLatLon=&featureType=&requestedTime=&startTime=&endTime=&compType=&propertyName=&product=glance&begin=#{begin_date}&end=#{end_date}&Unit=e&wx=wx&Submit=Submit"
    
    logger.debug "Pulling forecast from #{build_url}"
    
    # Default return
    forecast = {:error => 'Unable to fetch forecast.'} 
    
    # Create a Hydra to handle our requests
    hydra = Typhoeus::Hydra.new
    
    # Build the request object
    request = Typhoeus::Request.new(build_url,  
                                    :follow_location => true)
    
    # Setup the completion handler                                
    request.on_complete do |response|
      if response.success?
        REXML::Document.new(response.body)
        forecast = Hash.from_xml(response.body)
        forecast = forecast['dwml'] if forecast['dwml']
        forecast = forecast['data'] if forecast['data']
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

    forecast # return the forecast
  end
  
end

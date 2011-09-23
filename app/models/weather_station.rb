class WeatherStation < ActiveRecord::Base
  ###############################################
  # Validations
  validates_uniqueness_of :identifier
  
  ###############################################
  # Geocoding
  reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode  # auto-fetch address
  
  
end

class WeatherStationsController < ApplicationController
  def index
    @weather_stations = WeatherStation.all
  end

  def show
    @weather_station = WeatherStation.find(params[:id])
  end

end

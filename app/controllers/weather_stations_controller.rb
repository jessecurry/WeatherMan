class WeatherStationsController < ApplicationController
  def index
    @weather_stations = WeatherStation.paginate(:page => params[:page])
  end

  def show
    @weather_station = WeatherStation.find(params[:id])
  end

end

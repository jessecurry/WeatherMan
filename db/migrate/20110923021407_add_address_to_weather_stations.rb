class AddAddressToWeatherStations < ActiveRecord::Migration
  def self.up
    add_column :weather_stations, :address, :string
  end

  def self.down
    remove_column :weather_stations, :address
  end
end

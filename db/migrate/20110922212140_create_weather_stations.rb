class CreateWeatherStations < ActiveRecord::Migration
  def self.up
    create_table :weather_stations do |t|
      t.string :identifier
      t.string :state
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :html_url
      t.string :rss_url
      t.string :xml_url

      t.timestamps
    end
    
    add_index :weather_stations, :identifier, :unique => true
    add_index :weather_stations, :latitude
    add_index :weather_stations, :longitude
  end

  def self.down
    drop_table :weather_stations
  end
end

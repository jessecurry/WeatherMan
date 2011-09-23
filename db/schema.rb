# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110923021407) do

  create_table "weather_stations", :force => true do |t|
    t.string   "identifier"
    t.string   "state"
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "html_url"
    t.string   "rss_url"
    t.string   "xml_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
  end

  add_index "weather_stations", ["identifier"], :name => "index_weather_stations_on_identifier", :unique => true
  add_index "weather_stations", ["latitude"], :name => "index_weather_stations_on_latitude"
  add_index "weather_stations", ["longitude"], :name => "index_weather_stations_on_longitude"

end

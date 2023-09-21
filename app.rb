require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  erb(:homepage)
end

post("/results") do
  @user_loc = params.fetch("user_location").upcase
  @user_loc_encoded = @user_loc.gsub(" ","+")

  # Assemble google geocode API URL
  @gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + @user_loc_encoded + "&key=" + ENV.fetch("GMAPS_KEY")

  # Place GET request to gmaps API URL
  @raw_resp_gmaps = HTTP.get(@gmaps_url)

  # Parse JSON response
  @parsed_resp_gmaps = JSON.parse(@raw_resp_gmaps)

  # Dig for user latitude and longitude values
  @results_array = @parsed_resp_gmaps.fetch("results")
  @results_hash = @results_array.fetch(0) 
  @geometry_hash = @results_hash.fetch("geometry")
  @location_hash = @geometry_hash.fetch("location")

  # Get user latitude
  @user_lat = @location_hash.fetch("lat")

  # Get user longitude
  @user_lng = @location_hash.fetch("lng")

  # Assemble pirate weather API url
  @pirate_url = "https://api.pirateweather.net/forecast/" + ENV.fetch("PIRATE_WEATHER_KEY") + "/" + @user_lat.to_s + "," + @user_lng.to_s
  
  # Place GET request to pirate weather
  @raw_resp_pirate = HTTP.get(@pirate_url)

  # Parse response
  @parsed_resp_pirate = JSON.parse(@raw_resp_pirate)

  # Dig for temp, humidity, chance of precip, and current condition values 
  @currently_hash = @parsed_resp_pirate.fetch("currently")

  @user_temp = @currently_hash.fetch("temperature")
  @user_humidity = @currently_hash.fetch("humidity")
  @user_precip_chance = @currently_hash.fetch("precipProbability")
  @user_current_conditions = @currently_hash.fetch("summary")
  @user_precip_type = @currently_hash.fetch("precipType")

  # top clothing items
  @cold_tops = ["Thermal base layer", "Long-sleeved top", "Light jacket"]

  @medium_tops = ["Shirt", "Long-sleeved pullover"] 
  
  @hot_tops = ["Singlet and/or Sports bra"]

  # bottom clothing items

  @hot_bottoms = ["Shorts"]

  @medium_bottoms = ["Runing Tights"]

  @cold_bottoms = ["Running Tights", "Shorts (over running tights)"]

  # head gear items
  @head_gear = "Cap"

  @cold_head_gear = "Beanie"

  # hand gear items
  @wet_hand_gear = "Wind/waterproof gloves"
  @cold_hand_gear = "Insulated, Moisture wicking gloves"
  
  erb(:user_results)
end

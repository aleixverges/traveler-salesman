require 'csv'

def distance(loc1, loc2)
  rad_per_deg = Math::PI/180  # PI / 180
  rkm = 6371                  # Earth radius in kilometers

  dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
  dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

  lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
  lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

  a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

  (rkm * c).round(2) # Distance in km
end

def shortest_trip(positions, destinies)
  distances = Hash.new
  origin_latitude = positions[0]
  origin_longitude = positions[1]

  destinies.each do |destiny_key, destiny_values|
    destiny_lat = destiny_values[0]
    destiny_long = destiny_values[1]

    distances[destiny_key] = (distance [origin_latitude.to_f, origin_longitude.to_f],[destiny_lat.to_f, destiny_long.to_f])
  end

  return shortest_distance(distances);
end

def read_cities(path)
  cities = Hash.new
  data = CSV.read(path, { encoding: 'UTF-8', headers: false, header_converters: :symbol, converters: :all, :col_sep => "\t"})

  data.each do |city|
    cities[city[0]] = [city[1], city[2]]
  end

  return cities
end

def shortest_distance(hash)
  hash.min_by{|k,v| v}
end

cities = read_cities(Dir.pwd + '/cities.txt')
departure_city = cities.keys[0]
trip_plan = Array.new

trip_plan << departure_city
current_city_positions = cities[departure_city]
cities.delete(departure_city)

for i in 0..cities.length - 1
  compare_cities = cities.clone
  next_destiny = shortest_trip(current_city_positions, compare_cities)
  trip_plan << next_destiny[0]
  current_city_positions = cities[next_destiny[0]]
  cities.delete(next_destiny[0])
end

puts trip_plan

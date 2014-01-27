defmodule Forecast.Haversine do
  @r 6371 # radius of the earth

  import :math, only: [sin: 1, cos: 1, acos: 1, pi: 0]

  def to_radians(degrees) do
    degrees * pi * 2 / 360
  end

  def deg_sin degrees do
    sin(to_radians(degrees))
  end

  def deg_cos degrees do
    cos(to_radians(degrees))
  end

  def distance_km {lat1, lon1}, {lat2, lon2} do
    acos(deg_sin(lat1) * deg_sin(lat2) + deg_cos(lat1) * deg_cos(lat2) * deg_cos(lon2 - lon1)) * @r
  end
end

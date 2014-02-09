defmodule Forecast.MetOffice.InterpretSiteList do
  import Forecast.Haversine, only: [distance_km: 2]
  def find_nearest(locations, current_location, count) do
    locations
      |> Enum.map(fn l ->
        [{:distance, distance_km(current_location, {l[:latitude], l[:longitude]})} | l]
      end)
        |> Enum.sort(fn lhs, rhs ->
          lhs[:distance] < rhs[:distance]
        end)
          |> Enum.take(count)
  end
end

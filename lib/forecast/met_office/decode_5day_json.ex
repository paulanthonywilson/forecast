defmodule Forecast.MetOffice.Decode5DayJson do
  import Forecast.MetOffice.Conversions, only: [safe_to_integer: 1]

  defrecord Header, name: nil, units: nil
  defrecord PointForecast, date: nil,
  time: nil,
  feels_like_temperature: nil,
  wind_gust: nil,
  screen_relative_humidity: nil,
  temperature: nil,
  visibility: nil,
  wind_direction: nil,
  wind_speed: nil,
  max_uv_index: nil,
  weather_type: nil

  def decode_forecasts [{"SiteRep", [_, {"DV", [_,_,{"Location",forecasts}]}]}] do
    forecasts["Period"]
      |> Enum.map(fn day_forecasts ->
        day = day_forecasts["value"]
        day_forecasts["Rep"]
          |> Enum.map(fn f ->
            PointForecast[
              feels_like_temperature: f["F"] |> safe_to_integer,
              wind_gust: f["G"] |> safe_to_integer,
              screen_relative_humidity: f["H"] |> safe_to_integer,
              temperature: f["T"] |> safe_to_integer,
              visibility: f["V"],
              wind_direction: f["D"],
              wind_speed: f["S"] |> safe_to_integer,
              max_uv_index: f["U"] |> safe_to_integer,
              weather_type: f["W"] |> safe_to_integer,

              ]
          end)

      end)
        |> List.flatten
  end
  def decode_forecasts json do
    json |> Jsonex.decode |> decode_forecasts
  end
end

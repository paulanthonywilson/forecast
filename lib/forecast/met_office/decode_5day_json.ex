defmodule Forecast.MetOffice.Decode5DayJson do
  import Forecast.MetOffice.Conversions, only: [safe_to_integer: 1, parse_date: 1, parse_date_time: 1, safe_to_float: 1]

  defrecord Forecast, location: nil, forecast_date_time: nil, forecasts: nil
  defrecord PointForecast,
    datetime: nil,
    feels_like_temperature: nil,
    wind_gust: nil,
    screen_relative_humidity: nil,
    temperature: nil,
    visibility: nil,
    wind_direction: nil,
    wind_speed: nil,
    max_uv_index: nil,
    weather_type: nil,
    chance_precipitation: nil

  defrecord Location,
    id: nil,
    latitude: nil,
    longitude: nil,
    name: nil,
    country: nil,
    continent: nil,
    elevation: nil

  def decode_forecasts [{"SiteRep", [_, {"DV", [_,_,{"Location",forecasts}]}]}] do
    forecasts["Period"]
      |> Enum.map(fn day_forecasts ->
        day = day_forecasts["value"] |> parse_date
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
              chance_precipitation: f["Pp"] |> safe_to_integer,
              datetime: {day, forecast_time(f)},
              ]
          end)

      end)
        |> List.flatten
  end


  def decode_location  [{"SiteRep", [_, {"DV", [_,_,{"Location",forecast}]}]}]  do
    Location[
      id: forecast["i"],
      latitude: forecast["lat"] |> safe_to_float,
      longitude: forecast["lon"] |> safe_to_float,
      name: forecast["name"],
      country: forecast["country"],
      continent: forecast["continent"],
      elevation: forecast["elevation"] |> safe_to_float,
      ]
  end

  def decode_forecast_date_time  [{"SiteRep", [_, {"DV", [{"dataDate", forecast_date_time},_,_]}]}]  do
    forecast_date_time |> parse_date_time
  end

  def decode_all json do
    data = json |> Jsonex.decode
    Forecast[
      location: decode_location(data),
      forecast_date_time: decode_forecast_date_time(data),
      forecasts: decode_forecasts(data)
      ]

  end

  defp forecast_time raw_forecast do
    minutes = safe_to_integer(raw_forecast["$"])
    {trunc(minutes / 60), rem(minutes, 60), 0}
  end

end

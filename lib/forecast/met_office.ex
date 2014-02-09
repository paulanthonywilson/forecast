defmodule Forecast.MetOffice do
  defmodule ApiData do
    alias HTTPotion.Response
    @api_key "f016d482-0238-42e0-919d-c580163410b3"

    @user_agent  [ "User-agent": "Elixir:"]


    def fetch(url_portion, params) do
      url = "http://datapoint.metoffice.gov.uk/public/data/val/#{url_portion}?#{param_string(params)}"
      case HTTPotion.get(url, @user_agent) do
        Response[body: body, status_code: status, headers: _headers ] when status in 200..299 -> body
        Response[body: body, status_code: status, headers: _headers ] -> raise "Met Office returned status code '#{status}' with body:\n#{body}"
      end
    end

    defp param_string(params) do
      (params ++ [key: @api_key]
        |> Enum.map(fn {key, val} -> "#{key}=#{val}" end))
        |> Enum.join("&")
    end
  end

  defmodule DecodeSiteList do

    def decode_site_list [{_,[{_, locations}]}] do
      locations
        |> Enum.map(fn l ->
          [
            elevation: Forecast.safe_to_float(l["elevation"]),
            id: l["id"],
            latitude: Forecast.safe_to_float(l["latitude"]),
            longitude: Forecast.safe_to_float(l["longitude"]),
            name: l["name"],
            region: l["region"],
            unitaryAuthArea: l["unitaryAuthArea"],
            ]
        end)

    end

    def decode_site_list json do
      json |> Jsonex.decode |> decode_site_list
    end

  end




  defmodule InterpretSiteList do
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

  defmodule Decode5DayJson do
    import Forecast, only: [safe_to_integer: 1]

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

  def nearest_sites(latlon, count) do
    ApiData.fetch("wxfcs/all/json/sitelist", [res: "daily"])
      |> DecodeSiteList.decode_site_list
      |> Interpret.find_nearest(latlon, count)
  end

  def site_5day_forecast(site_id) do
    ApiData.fetch("wxfcs/all/json/#{site_id}", [res: "3hourly"])
      |> Decode5DayJson.decode_forecasts
  end

end


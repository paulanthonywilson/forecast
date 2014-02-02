defmodule Forecast.MetOffice do
  defmodule ApiData do
    alias HTTPotion.Response
    @api_key "f016d482-0238-42e0-919d-c580163410b3"

    @user_agent  [ "User-agent": "Elixir:"]


    def fetch(url_portion, params) do
      url = "http://datapoint.metoffice.gov.uk/public/data/val/#{url_portion}?#{param_string(params)}"
      case HTTPotion.get(url, @user_agent) do
        Response[body: body, status_code: status, headers: _headers ] when status in 200..299 -> { :ok, body }
        Response[body: body, status_code: _status, headers: _headers ] -> { :error, body }
      end
    end

    defp param_string(params) do
      (params ++ [key: @api_key]
        |> Enum.map(fn {key, val} -> "#{key}=#{val}" end))
        |> Enum.join("&")
    end
  end

  defmodule Decode do
    defp safe_to_float(nil) do 0.0 end
    defp safe_to_float(s) do
      case Float.parse(s) do
        {result, _remainder} -> result
      end
    end

    def decode_site_list [{_,[{_, locations}]}] do
      locations
        |> Enum.map(fn l ->
          [
            elevation: safe_to_float(l["elevation"]),
            id: l["id"],
            latitude: safe_to_float(l["latitude"]),
            longitude: safe_to_float(l["longitude"]),
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


  defmodule Interpret do
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

  def site_list do
    case ApiData.fetch("wxfcs/all/json/sitelist", [res: "daily"]) do
      {:ok, json} -> json |> Decode.decode_site_list
      {status, body} -> {status, body}
    end
  end

  def nearest_sites(latlon, count) do
    case site_list do
      error = {:error, body} -> error
      locations -> Interpret.find_nearest(locations, latlon, count)
    end
  end

end


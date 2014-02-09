
defmodule Forecast.MetOffice.DecodeSiteList do
  import Forecast.MetOffice.Conversions, only: [safe_to_float: 1]

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

defmodule Forecast.MetOffice do







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


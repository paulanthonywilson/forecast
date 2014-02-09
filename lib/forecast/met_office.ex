defmodule Forecast.MetOffice do
  alias Forecast.MetOffice.ApiData
  alias Forecast.MetOffice.DecodeSiteList
  alias Forecast.MetOffice.Decode5DayJson
  alias Forecast.MetOffice.InterpretSiteList

  def nearest_sites(latlon, count) do
    ApiData.fetch("wxfcs/all/json/sitelist", [res: "daily"])
      |> DecodeSiteList.decode_site_list
      |> InterpretSiteList.find_nearest(latlon, count)
  end

  def site_5day_forecast(site_id) do
    ApiData.fetch("wxfcs/all/json/#{site_id}", [res: "3hourly"])
      |> Decode5DayJson.decode_all
  end

end


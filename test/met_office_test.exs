defmodule MetOfficeDataTest do
  use ExUnit.Case
  alias HTTPotion.Response
  import Forecast.MetOffice.ApiData, only: [fetch: 2]

  setup do
    :meck.new(HTTPotion)
    :ok
  end

  teardown do
    :meck.unload(HTTPotion)
    :ok
  end

  defp stub_httpotion_get(f) do
    :meck.expect(HTTPotion, :get, f)
  end


  test "successful request returns ok with the body" do
    stub_httpotion_get fn _url, _agent -> Response[status_code: 200, body: "everything is fine"] end

    assert Forecast.MetOffice.ApiData.fetch("hi", []) == "everything is fine"
  end

  test "unsuccessful request raises an exception" do
    stub_httpotion_get fn _url, _agent -> Response[status_code: 500, body: "everything is terrible"] end
    assert_raise RuntimeError, "Met Office returned status code '500' with body:\neverything is terrible", fn ->
      assert Forecast.MetOffice.ApiData.fetch("hi", []) == {:error, "everything is terrible"}
    end
  end


  test "the metoffice url is used with the api key" do
    stub_httpotion_get fn url, _ ->
      assert url == "http://datapoint.metoffice.gov.uk/public/data/val/abc/def?key=f016d482-0238-42e0-919d-c580163410b3"
      Response[status_code: 200]
    end

    fetch "abc/def", []

  end

  test "url with extra parameter" do
    stub_httpotion_get fn url, _ ->
      assert url == "http://datapoint.metoffice.gov.uk/public/data/val/abc/def?res=daily&key=f016d482-0238-42e0-919d-c580163410b3"
      Response[status_code: 200]
    end

    fetch "abc/def", [res: "daily"]
  end

end


defmodule ApiDecodeTest do
  use ExUnit.Case
  import Forecast.MetOffice.Decode

  def locations_json do
    File.read!("#{__DIR__}/locations_fixture.json")
  end

  test "decodes the locations Json" do
    assert (locations_json |> decode_site_list) == [
      [elevation: 933.0, id: "3072", latitude: 56.879, longitude: -3.42, name: "Cairnwell", region: "ta", unitaryAuthArea: "Perth and Kinross"],
      [elevation: 134.0, id: "3088", latitude: 56.852, longitude: -2.264, name: "Inverbervie", region: "gr", unitaryAuthArea: "Aberdeenshire"]]
  end
end


defmodule InterpretSiteListTest do
  use ExUnit.Case
  import Forecast.MetOffice.InterpretSiteList, only: [find_nearest: 3]

  setup do
    :meck.new(Forecast.Haversine)
    :ok
  end

  teardown do
    :meck.unload(Forecast.Haversine)
    :ok
  end

  def locations do
    1..5 |> Enum.map(fn i -> [latitude: 56.0 + i / 10, longitude: -3.0] end)
  end

  test "find the nearest, finds the nearest" do
    :meck.expect(Forecast.Haversine, :distance_km,
    fn {lat1, lon1}, {lat2, lon2} ->
      assert lat1 == 56.6
      assert lon1 == -3.0
      assert lon2 == -3.0

      (lat1 - lat2) * 10 |> Float.floor
    end)

    assert find_nearest(locations, {56.6, -3.0}, 1) == [[distance: 1, latitude: 56.5, longitude: -3.0]]

  end
end

defmodule DecodeFiveDaySiteForcast do
  use ExUnit.Case
  import Forecast.MetOffice.Decode5DayJson, only: [decode_forecasts: 1]
  alias Forecast.MetOffice.Decode5DayJson.Header

  def site5day_json do
    File.read!("#{__DIR__}/site5day_fixture.json") |> Jsonex.decode
  end


  test "decode forecasts" do
    forecasts = site5day_json |> decode_forecasts
    assert (forecasts |> length) == 34 #?? check
    [first|_] = forecasts
    assert first.feels_like_temperature == 6
    assert first.wind_gust == 40
    assert first.screen_relative_humidity == 73
    assert first.temperature == 10
    assert first.visibility == "VG"
    assert first.wind_direction == "SW"
    assert first.wind_speed == 25
    assert first.max_uv_index == 0
    assert first.weather_type == 7

  end


end

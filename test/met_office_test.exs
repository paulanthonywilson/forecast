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

    assert Forecast.MetOffice.ApiData.fetch("hi", []) == {:ok, "everything is fine"}
  end

  test "unnsuccessful request returns error with the body" do
    stub_httpotion_get fn _url, _agent -> Response[status_code: 500, body: "everything is terrible"] end
    assert Forecast.MetOffice.ApiData.fetch("hi", []) == {:error, "everything is terrible"}
  end


  test "the metoffice url is used with the api key" do
    stub_httpotion_get fn url, _ ->
      assert url == "http://datapoint.metoffice.gov.uk/public/data/val/abc/def?key=f016d482-0238-42e0-919d-c580163410b3"
      Response.new
    end

    fetch "abc/def", []

  end

  test "url with extra parameter" do
    stub_httpotion_get fn url, _ ->
      assert url == "http://datapoint.metoffice.gov.uk/public/data/val/abc/def?res=daily&key=f016d482-0238-42e0-919d-c580163410b3"
      Response.new
    end

    fetch "abc/def", [res: "daily"]
  end

end


defmodule ApiDecodeTest do
  use ExUnit.Case
  import Forecast.MetOffice.Decode

  def locations_json do
    File.read!("#{Path.dirname(__FILE__)}/locations_fixture.json")
  end

  test "decodes the Json" do
    assert (locations_json |> decode_site_list) == "hello"
  end
end


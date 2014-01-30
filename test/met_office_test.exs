defmodule MetOfficeDataTest do
  use ExUnit.Case
  alias HTTPotion.Response

  setup do
    :meck.new(HTTPotion)
    :ok
  end


  test "successful status returns ok with the body" do
    :meck.expect(HTTPotion, :get, fn _url, _agent -> Response[status_code: 200, body: "everything is fine"] end
    )

    assert Forecast.MetOffice.ApiData.fetch("hi") == {:ok, "everything is fine"}
  end
end

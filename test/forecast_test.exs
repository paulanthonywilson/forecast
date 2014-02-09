defmodule ForecastTest do
  use ExUnit.Case

  setup do
    :meck.new(Forecast.MetOffice)
    :ok
  end

  teardown do
    :meck.unload(Forecast.MetOffice)
    :ok
  end

  test "returns ok without exception" do
    :meck.expect(Forecast.MetOffice, :nearest_sites, fn latlon, count->
      assert latlon == {55.6, -3.1}
      assert count == 4
      "sites!"
    end);

    assert Forecast.nearest_sites({55.6, -3.1}, 4) == {:ok, "sites!"}
  end

  test "returns error when there's an exception" do
    :meck.expect(Forecast.MetOffice, :nearest_sites, fn _latlon, _count->
      raise "Oh dear!"
    end);

    assert Forecast.nearest_sites({55.6, -3.1}, 4) == {:error, "Oh dear!"}

  end


  test "safe parse integer" do
    assert Forecast.safe_to_integer("5") == 5
    assert Forecast.safe_to_integer("5.6") == 5
    assert Forecast.safe_to_integer(nil) == 0
    assert Forecast.safe_to_integer("oooh") == 0
  end

  test "safe parse float" do
    assert Forecast.safe_to_float("5") == 5.0
    assert Forecast.safe_to_float("5.6") == 5.6
    assert Forecast.safe_to_float(nil) == 0.0
    assert Forecast.safe_to_float("oooh") == 0.0
  end
end

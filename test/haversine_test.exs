defmodule HaversineTest do
  use ExUnit.Case
  import Forecast.Haversine, only: [distance_km: 2]

  test "distances" do
    assert_in_delta 99.10, distance_km({54.667, -5.75}, {54.711, -4.21}), 0.1
    assert_in_delta 678.3, distance_km({51.064486, -1.315269}, {57.148161, -2.090492}), 0.1 # Winchester to Aberdeen
  end
end

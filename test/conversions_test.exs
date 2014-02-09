defmodule ConversionsTest do
  use ExUnit.Case
  import Forecast.MetOffice.Conversions

  test "safe parse integer" do
    assert safe_to_integer("5") == 5
    assert safe_to_integer("5.6") == 5
    assert safe_to_integer(nil) == 0
    assert safe_to_integer("oooh") == 0
  end

  test "safe parse float" do
    assert safe_to_float("5") == 5.0
    assert safe_to_float("5.6") == 5.6
    assert safe_to_float(nil) == 0.0
    assert safe_to_float("oooh") == 0.0
  end
end

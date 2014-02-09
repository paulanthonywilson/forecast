defmodule Forecast.MetOffice.Conversions do
  def safe_to_float(nil) do 0.0 end
  def safe_to_float(s) do
    case Float.parse(s) do
      {result, _remainder} -> result
      :error -> 0
    end
  end


  def safe_to_integer(nil) do 0 end
  def safe_to_integer(s) do
    case Integer.parse(s) do
      {result, _remainder} -> result
      :error -> 0
    end
  end
end

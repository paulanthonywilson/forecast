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

  def parse_date date_string do
    Regex.named_captures(%r/^(?<y>\d{4})-(?<m>\d{2})-(?<d>\d{2})Z$/g, date_string)
      |> Enum.map(fn {_name, value} ->
        safe_to_integer(value)
      end)
      |> list_to_tuple
  end

  def parse_date_time date_string do
    Regex.named_captures(%r/^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})T(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})/g, date_string)
      |> values_to_integers
      |> date_time_captures_to_date_time

  end

  defp values_to_integers keyword_list do
    keyword_list
      |> Enum.map(fn {name, value} ->
        {name, safe_to_integer(value)}
      end)
  end

  defp date_time_captures_to_date_time captures do
    {{captures[:year], captures[:month], captures[:day]}, {captures[:hour], captures[:minute], captures[:second]}}
  end



end

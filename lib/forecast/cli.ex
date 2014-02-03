defmodule Forecast.CLI do
  @default_count  4
  import Forecast.MetOffice, only: [nearest_sites: 2]
  import Forecast.TableFormatter, only: [print_table_for_columns: 2]

  def main(_argv) do
    latitude = get_float("Latitude?")
    longitude = get_float("Longitude?")
    count = get_count
    nearest_sites({latitude, longitude}, count)
      |> print_table_for_columns [:id, :name, :distance, :unitaryAuthArea, :elevation, :latitude, :longitude]
  end

  def get_float(prompt) do
    case IO.gets("#{prompt} ") |> String.strip |> Float.parse do
      :error -> get_float(prompt)
      {value, _} -> value
    end
  end


  def get_count do
    case IO.gets("How many? (4) ") |> String.strip do
      "" -> 4
      answer -> case Integer.parse(answer) do
        :error -> get_count
        {value, _} -> value
      end
    end
  end





end


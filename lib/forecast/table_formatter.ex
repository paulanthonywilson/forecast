defmodule Forecast.TableFormatter do

  def split_into_columns data, headers do
    headers |> Enum.map fn header ->
      data |> Enum.map fn row ->
        row[header] |> to_string
      end
    end
  end

  def widths_of columns do
    columns |> Enum.map fn column_rows ->
      column_rows |> Enum.reduce 0, fn row, acc ->
        max(String.length(row), acc)
      end
    end
  end

  def format_for column_widths do
    (column_widths
      |> Enum.map(fn width -> "~-#{width}s" end)
      |> Enum.join(" | "))
    <>  "~n"
  end


  def print_table_for_columns data, headers do
    columns = split_into_columns(data, headers)
    column_widths = widths_of(columns)
    format = format_for(column_widths)

    :io.format(format, headers)
    IO.puts Enum.map_join(column_widths, "-+-", &(List.duplicate('-', &1)))

    columns
      |> List.zip
      |> Enum.map(&tuple_to_list/1)
      |> Enum.each(&(:io.format(format, &1)))

  end

end

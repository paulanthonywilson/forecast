defmodule Forecast do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Forecast.Supervisor.start_link
  end

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


  def nearest_sites(latlon, count) do
    try do
    {:ok, Forecast.MetOffice.nearest_sites(latlon, count)}
    rescue
      e in [RuntimeError] -> {:error, e.message}
    end
  end
end

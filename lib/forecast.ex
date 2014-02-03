defmodule Forecast do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Forecast.Supervisor.start_link
  end

  def nearest_sites(latlon, count) do
    try do
    {:ok, Forecast.MetOffice.nearest_sites(latlon, count)}
    rescue
      e in [RuntimeError] -> {:error, e.message}
    end
  end
end

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

  def site_5day_forecast(site_id) do
    try do
    {:ok, Forecast.MetOffice.site_5day_forecast(site_id)}
    rescue
      e in [RuntimeError] -> {:error, e.message}
    end
  end
end

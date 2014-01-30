defmodule Forecast.MetOffice do
  defmodule ApiData do
    alias HTTPotion.Response

    @user_agent  [ "User-agent": "Elixir:"]

    def fetch(url) do
      case HTTPotion.get(url, @user_agent) do
        Response[body: body, status_code: status, headers: _headers ] when status in 200..299 -> { :ok, body }
        Response[body: body, status_code: _status, headers: _headers ] -> { :error, body }
      end
    end
  end
  @api_key "f016d482-0238-42e0-919d-c580163410b3"

  def site_list do
    "http://datapoint.metoffice.gov.uk/public/data/val/wxfcs/all/json/sitelist?res=daily&key=#{@api_key}"
      |> ApiData.fetch
  end
end


defmodule Forecast.MetOffice.ApiData do
  alias HTTPotion.Response
  @api_key "f016d482-0238-42e0-919d-c580163410b3"

  @user_agent  [ "User-agent": "Elixir:"]


  def fetch(url_portion, params) do
    url = "http://datapoint.metoffice.gov.uk/public/data/val/#{url_portion}?#{param_string(params)}"
    case HTTPotion.get(url, @user_agent) do
      Response[body: body, status_code: status, headers: _headers ] when status in 200..299 -> body
      Response[body: body, status_code: status, headers: _headers ] -> raise "Met Office returned status code '#{status}' with body:\n#{body}"
    end
  end

  defp param_string(params) do
    (params ++ [key: @api_key]
      |> Enum.map(fn {key, val} -> "#{key}=#{val}" end))
      |> Enum.join("&")
  end
end

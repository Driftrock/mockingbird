defmodule Mockingbird.HTTPoisonHttpClient do
  def call(verb, url, params \\ [], headers \\ [])
  def call(:get, url, params, headers) do
    url = url_with_params(url, params)
    HTTPoison.get(url, headers)
  end

  defp url_with_params(url, params), do: uri_with_params(url, params) |> URI.to_string

  defp uri_with_params(url, []), do: URI.parse(url)
  defp uri_with_params(url, params), do: %{ URI.parse(url) | query: URI.encode_query(params) }
end

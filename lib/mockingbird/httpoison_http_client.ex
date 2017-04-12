defmodule Mockingbird.HTTPoisonHttpClient do
  @moduledoc """
  This is the live client. It's where Mockingbird routes the live calls to by
  default.
  """

  @doc """
  This will instruct HTTPoison to perform the request.

  Return HTTPoison normal values (an `{:ok, response}` tuple if the request is
  fulfilled, an `{:error, error}` tuple if the request cannot be performed)

  The first parameter must be one of the following atoms: `:delete`, `:get`,
  `:head`, `:options`, `:patch`, `:post`.

  The query string for a get call can be either incorporated in the url or
  passed as a map. The body for all other methods need to be a binary (e.g.: a
  string with a JSON-encoded structure).
  """
  @spec call(atom, binary, map | binary, map) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  def call(verb, url, body \\ %{}, headers \\ %{})

  def call(:delete, url, _body, headers) do
    HTTPoison.delete(url, headers)
  end

  def call(:get, url, params, headers) do
    url = url_with_params(url, params)
    HTTPoison.get(url, headers)
  end

  def call(:head, url, _body, headers) do
    HTTPoison.head(url, headers)
  end

  def call(:options, url, _body, headers) do
    HTTPoison.options(url, headers)
  end

  def call(:patch, url, body, headers) do
    HTTPoison.patch(url, body, headers)
  end

  def call(:post, url, body, headers) do
    HTTPoison.post(url, body, headers)
  end

  defp url_with_params(url, params) when params == %{}, do: url
  defp url_with_params(url, params), do: url |> add_query_to_url(params)

  defp add_query_to_url(url, params) do
    %{URI.parse(url) | query: URI.encode_query(params)} |> URI.to_string
  end
end

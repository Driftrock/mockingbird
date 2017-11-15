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
  @spec call(atom, binary, map | binary, map, Keyword.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def call(verb, url, body \\ %{}, headers \\ %{}, options \\ [])

  def call(verb, url, body, headers, options) do
    do_call(verb, url, body, headers, options, 0)
  end

  defp do_call(_verb, _url, _body, _headers, _options, 3) do
    raise %HTTPoison.Error{reason: :closed}
  end

  defp do_call(verb, url, body, headers, options, attempt) do
    case perform_call(verb, url, body, headers, options) do
      {:error, %HTTPoison.Error{id: nil, reason: :closed}} ->
        do_call(verb, url, body, headers, options, attempt + 1)

      res ->
        res
    end
  end

  defp perform_call(:delete, url, _body, headers, options) do
    HTTPoison.delete(url, headers, options)
  end

  defp perform_call(:get, url, params, headers, options) do
    url = url_with_params(url, params)
    HTTPoison.get(url, headers, options)
  end

  defp perform_call(:head, url, _body, headers, options) do
    HTTPoison.head(url, headers, options)
  end

  defp perform_call(:options, url, _body, headers, options) do
    HTTPoison.options(url, headers, options)
  end

  defp perform_call(:patch, url, body, headers, options) do
    HTTPoison.patch(url, body, headers, options)
  end

  defp perform_call(:post, url, body, headers, options) do
    HTTPoison.post(url, body, headers, options)
  end

  defp perform_call(:put, url, body, headers, options) do
    HTTPoison.put(url, body, headers, options)
  end

  defp url_with_params(url, params) when params == %{}, do: url
  defp url_with_params(url, params), do: url |> add_query_to_url(params)

  defp add_query_to_url(url, params) do
    %{URI.parse(url) | query: URI.encode_query(params)} |> URI.to_string()
  end
end

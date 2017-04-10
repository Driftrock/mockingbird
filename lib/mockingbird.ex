defmodule Mockingbird do
  @moduledoc """
  Documentation for Mockingbird.
  """

  @doc false
  defmacro __using__(opts) do
    client = client_by_env(opts)

    quote do
      @http_client unquote(client)
    end
  end

  defp client_by_env(opts) do
    env = Keyword.get(opts, :env) || Mix.env

    case env do
      :test -> Keyword.get(opts, :test_client)
      _ -> live_client(opts)
    end
  end

  defp live_client(opts) do
    Keyword.get(opts, :live_client) || Application.get_env(:mockingbird, :live_client, Mockingbird.HTTPoisonHttpClient)
  end
end

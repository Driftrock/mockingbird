defmodule Mockingbird do
  @moduledoc """
  Mockingbird helps you create API consumers that are easy to test.

  ## Usage

      # lib/my_app/git.ex
      defmodule MyApp.Git do
        use Mockingbird, mock_client: MyApp.GitMockHttpClient

        def get_account_info(username) do
          @http_client.call(:get, "https://api.github.com/users/" <> username)
        end
      end

      # test/support/git_mock_http_client.ex
      defmodule MyApp.GitMockHttpClient do
        use Mockingbird.FakeClient

        # All the `call` methods you plan to use in tests will need a function head
        # that will match test usage
        def call(:get, "https://api.github.com/users/amencarini") do
          respond :ok, 200, \"""
          {
            "login": "amencarini",
            "id": 1100003
          }
          \"""
        end
      end

      # test/my_app/git_test.exs
      defmodule MyApp.GitTest do
        use ExUnit.Case

        describe "MyApp.Git.get_account_info/1" do
          test "it returns data for the selected user" do
            {:ok, res} = MyApp.Git.get_account_info("amencarini")
            assert Poison.decode(res.body) == %{"login" => "amencarini", "id" => 1100003}
          end
        end
      end

  ## Options

      use Mockingbird, mock_client: MyApp.GitMockHttpClient, live_client: MyApp.CustomHttpClient

  - `mock_client`: specify what module will contain the mocked responses
  - `live_client`: use a custom http client for live calls. Mockingbirg comes
    with a client that performs calls through HTTPoison.
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
      :test -> Keyword.fetch!(opts, :test_client)
      _ -> live_client(opts)
    end
  end

  defp live_client(opts) do
    Keyword.get(opts, :live_client) || Application.get_env(:mockingbird, :live_client, Mockingbird.HTTPoisonHttpClient)
  end
end

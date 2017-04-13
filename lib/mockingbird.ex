defmodule Mockingbird do
  @moduledoc """
  Mockingbird helps you create API consumers that are easy to test.

  ## Usage

      # lib/my_app/git.ex
      defmodule MyApp.Git do
        use Mockingbird, test: MyApp.GitMockHttpClient

        def get_account_info(username) do
          http_client().call(:get, "https://api.github.com/users/" <> username)
        end
      end

      # test/support/git_mock_http_client.ex
      defmodule MyApp.GitMockHttpClient do
        use Mockingbird.Client

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

      use Mockingbird, test: MyApp.GitMockHttpClient, live_client: MyApp.CustomHttpClient

  - `test`: specify what module will contain the mocked responses when used in
    the test environment.
  - `live_client`: use a custom http client for live calls. Mockingbirg comes
    with a client that performs calls through HTTPoison.
  """

  @doc false
  defmacro __using__(opts) do
    clients = clients(opts) |> Enum.into(%{}, fn({k, v}) -> {k, Macro.expand(v, __CALLER__)} end)

    quote do
      @clients unquote(clients |> Macro.escape)

      defp http_client do
        receive do
          :use_live_client -> Map.get(@clients, :live_client)
        after
          0 -> Map.get(@clients, Mix.env) || Map.get(@clients, :live_client)
        end
      end

      def with_live_client(do: block) do
        send self(), :use_live_client
        block.()
      end
    end
  end

  defp clients(opts) do
    if Keyword.has_key?(opts, :client) do
      []
      |> Keyword.put(Mix.env,  Keyword.get(opts, :client))
      |> Keyword.put(:live_client, live_client(opts))
    else
      Keyword.put(opts, :live_client, live_client(opts))
    end
  end

  defp live_client(opts) do
    Keyword.get(opts, :live_client) || Application.get_env(:mockingbird, :live_client, Mockingbird.HTTPoisonHttpClient)
  end
end

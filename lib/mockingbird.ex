defmodule Mockingbird do
  @moduledoc """
  Mockingbird helps you create API consumers that are easy to test.

  ## Usage

      # lib/my_app/github.ex
      defmodule MyApp.Github do
        use Mockingbird, test: MyApp.MockGithubHttpClient

        def get_account_info(username) do
          http_client().call(:get, "https://api.github.com/users/" <> username)
        end
      end

      # test/support/mock_github_http_client.ex
      defmodule MyApp.MockGithubHttpClient do
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

      # test/my_app/github_test.exs
      defmodule MyApp.GithubTest do
        use ExUnit.Case

        describe "MyApp.Github.get_account_info/1" do
          test "it returns data for the selected user" do
            {:ok, res} = MyApp.Github.get_account_info("amencarini")
            assert Poison.decode(res.body) == %{"login" => "amencarini", "id" => 1100003}
          end
        end
      end


  ## Options

      use Mockingbird, test: MyApp.MockGithubHttpClient, live_client: MyApp.RealHttpClient

  - `test`: specify what module will contain the mocked responses when used in
    the test environment.
  - `live_client`: use a custom http client for live calls. Mockingbirg comes
    with a client that performs calls through HTTPoison.
  """

  @doc false
  defmacro __using__(opts) do
    clients =
      opts |> clients() |> Enum.into(%{}, fn {k, v} -> {k, Macro.expand(v, __CALLER__)} end)

    quote do
      @clients unquote(clients |> Macro.escape())
      @default_fallback_client Mockingbird.HTTPoisonHttpClient

      defp http_client do
        receive do
          {:force_client_env, env} ->
            send(self(), {:force_client_env, env})
            Map.get(@clients, env) || default_client()
        after
          # If the mailbox does not have a message matching as above, the
          # following gets executed immediately.
          0 ->
            Map.get(@clients, Mix.env()) || default_client()
        end
      end

      defmacro with_client(env, do: block) do
        quote do
          send(self(), {:force_client_env, unquote(env)})
          unquote(block)

          receive do
            {:force_client_env, env} -> :ok
          end
        end
      end

      defp default_client() do
        Map.get(@clients, :default_client) ||
          Application.get_env(:mockingbird, :default_client, @default_fallback_client)
      end
    end
  end

  defp clients(opts) do
    if Keyword.has_key?(opts, :client) do
      []
      |> Keyword.put(:default_client, Keyword.get(opts, :client))
    else
      opts
    end
  end
end

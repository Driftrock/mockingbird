# Mockingbird

Mockingbird helps you create API consumers that are easy to test.

## Installation

Add `mockingbird` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:mockingbird, "~> 0.1.0"}]
end
```

## Usage

```elixir
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
    respond :ok, 200, """
    {
      "login": "amencarini",
      "id": 1100003
    }
    """
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
```

## Configuration

Mockingbird uses HTTPoison as default for live HTTP calls, but you can create or customise your live client.

```elixir
# config/config.exs
config :mockingbird,
  live_client: MyApp.CustomHttpClient

# lib/my_app/custom_tesla_client.ex
defmodule MyApp.CustomHttpClient do
  def call(verb, url, params, headers) do
    # Do your magic here
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mockingbird](https://hexdocs.pm/mockingbird).

# Mockingbird

The easiest way to test external API calls in your elixir application.

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

  def get_account_info do
    @api_client.call(:get, "https://api.github.com/users/amencarini")
  end

  def update_company(new_company) do
    @api_client.call(:patch, "https://api.github.com/user", company: new_company, %{"Authorization" => "token 321"})
  end
end

# test/support/git_mock_http_client.ex
defmodule MyApp.GitMockHttpClient do
  use Mockingbird.FakeClient

  def call(:get, "https://api.github.com/users/amencarini") do
    respond :ok, 200, """
    {
      "login": "amencarini",
      "id": 1100003
    }
    """
  end

  def call(:get, %URI{path: ("/user")}, %{"Authorization" => "token GoodToken"}) do
    respond :ok, 200, """
    {
      "currency": "GBP",
      "name": "Driftrock",
      "timezone_name": "Europe/London"
    }
    """
  end

  def call(:get, %URI{path: ("/user")}, %{"Authorization" => "token BadToken"}) do
    respond :ok, 401, """
    {
      "message": "Requires authentication",
      "documentation_url": "https://developer.github.com/v3"
    }
    """
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

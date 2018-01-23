# Mockingbird

[![Build Status](https://travis-ci.org/Driftrock/mockingbird.svg?branch=master)](https://travis-ci.org/Driftrock/mockingbird)

[![Inline docs](http://inch-ci.org/github/Driftrock/mockingbird.svg)](http://inch-ci.org/github/Driftrock/mockingbird)

Mockingbird helps you create API consumers that are easy to test.

## Installation

Add `mockingbird` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # ...
    {:mockingbird, "~> 0.1.1"},
    # ...
  ]
end
```

## Usage

```elixir
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

  # Define `call` methods for each `call` head (ie. verb, url, params) you
  # want to mock for tests
  # `respond` helper method returns struct mimicking HTTPoison.Response
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
defmodule MyApp.GithubTest do
  use ExUnit.Case

  describe "MyApp.Github.get_account_info/1" do
    test "it returns data for the selected user" do
      {:ok, res} = MyApp.Github.get_account_info("amencarini")
      assert Poison.decode(res.body) == %{"login" => "amencarini", "id" => 1100003}
    end
  end
end
```

### Fallback on live client

Sometimes you might want to fallback on the live client inside tests (e.g.: you have some
tests running against the live API you're consuming.) To do so, wrap your test
in a `with_client(environment)` call:

```elixir
# test/my_app/github_test.exs
defmodule MyApp.GithubTest do
  use ExUnit.Case

  describe "MyApp.Github.get_account_info/1" do
    test "checks the real API hasn't changed" do
      require  MyApp.Github # Needed to get the `with_client` macro available

      MyApp.Github.with_client(:prod) do
        {:ok, res} = MyApp.Github.get_account_info("amencarini")
        assert Poison.decode(res.body) == %{"login" => "amencarini", "id" => 1100003}
      end
    end
  end
end
```

## Configuration

Mockingbird uses HTTPoison as default for HTTP calls when key for current
environment is not set in `use`. You can create or customise your default client. You can either specify this globally at config level:

```elixir
# config/config.exs
config :mockingbird,
  default_client: MyApp.RealHttpClient
```

Or on a consumer basis for specific environments:

```elixir
# lib/my_app/github.ex
defmodule MyApp.Github do
  use Mockingbird,
    test: MyApp.MockGithubHttpClient
    prod: MyApp.RealHttpClient

  def get_account_info(username) do
    http_client().call(:get, "https://api.github.com/users/" <> username)
  end
end
```

Your live client just needs to implement a `call` function that pattern matches
on http verb, url, params and headers.

```elixir
# lib/my_app/real_http_client.ex
defmodule MyApp.RealHttpClient do
  def call(verb, url, params, headers) do
    # Do your magic here
  end
end
```

In fact client interface is the same for live and test clients. It is only
convenient to have default client for live and on the other hand have few helpers
in test clients.

### Clients per environment

You might want to set different clients per different environments. To do so you
can setup your consumer with a list of clients to use. Keys matches with current
`Mix.env`.

```elixir
# lib/my_app/github.ex
defmodule MyApp.Github do
  use Mockingbird,
    test: MyApp.MockGithubHttpClient,
    staging: MyApp.StagingHttpClient

  def get_account_info(username) do
    http_client().call(:get, "https://api.github.com/users/" <> username)
  end
end
```

You can achieve the same by pointing to a `Mix.config` item. If no configuration
is found Mockingbird will fallback on the live client.

```elixir
# config/test.exs
config :my_app,
  github_http_client: MyApp.MockGithubHttpClient

# lib/my_app/github.ex
defmodule MyApp.Github do
  use Mockingbird, client: Application.get_env(:my_app, :github_http_client)

  def get_account_info(username) do
    # This will use `MyApp.GitMockHttpClient` on test, and the real http client
    # in all other environments.
    http_client().call(:get, "https://api.github.com/users/" <> username)
  end
end
```

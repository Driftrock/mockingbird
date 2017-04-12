defmodule Mockingbird.FakeClient do
  defmodule Response do
    @moduledoc """
    A struct that holds the mocked response.
    """

    defstruct status_code: nil, body: nil, headers: []
    @type t :: %__MODULE__{status_code: integer, body: binary, headers: list}
  end

  defmodule Error do
    @moduledoc """
    The exception that will be passed when the mocked response is requested with
    `:error` as a parameter
    """

    defexception [:message]
     @type t :: %__MODULE__{message: binary}
  end

  @moduledoc ~S"""
  Set of helpers to be used in the module that contains the mocked respnoses.
  """

  @doc """
  Returns `{:ok, response}` if an `:ok` is passed as a first parameter, or
  `{:error, exception}` if `:error` is passed.

      # test/support/git_mock_http_client.ex
      defmodule MyApp.GitMockHttpClient do
        use Mockingbird.FakeClient

        def call(:get, "https://api.github.com/users/amencarini") do
          respond :ok, 200, \"""
          {
            "login": "amencarini",
            "id":1100003
          }
          \"""
        end
      end
  """
  @spec respond(:ok | :error, integer, binary) :: {:ok, Response.t} | {:error, Error.t}
  def respond(result, status, body, headers \\ [])

  def respond(:ok, status, body, headers) do
    {:ok, %Response{body: body, status_code: status, headers: headers}}
  end

  def respond(:error, _status, message, _headers) do
    {:error, %Error{message: message}}
  end
end

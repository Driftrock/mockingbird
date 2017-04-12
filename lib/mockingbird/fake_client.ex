defmodule Mockingbird.FakeClient do
  defmodule Response do
    defstruct status_code: nil, body: nil, headers: []
    @type t :: %__MODULE__{status_code: integer, body: binary, headers: list}
  end

  defmodule Error do
    defexception [:message]
     @type t :: %__MODULE__{message: binary}
  end

  @moduledoc ~S"""
  Set of helpers to be used in the module that contains the canned respnoses.
  """

  @doc """
  Returns a tuple the way HTTPoison does after a request. e.g.:

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

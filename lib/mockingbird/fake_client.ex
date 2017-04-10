defmodule Mockingbird.FakeClient do
  def respond(:ok, status, body), do: {:ok, %HTTPoison.Response{ body: body, status_code: status } }
end

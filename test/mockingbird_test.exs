defmodule MockingbirdTest do
  use ExUnit.Case

  import Mock

  defmodule MockHttpClient do
    import Mockingbird.FakeClient

    def call(_verb, _url) do
      respond :ok, 200, "ok"
    end
  end

  defmodule TestApiConsumer do
    use Mockingbird, test_client: MockHttpClient

    def test do
      @http_client.call(:get, "http://example.com")
    end
  end

  defmodule LiveApiConsumer do
    use Mockingbird, test_client: MockHttpClient, env: :dev

    def test do
      @http_client.call(:get, "http://example.com")
    end
  end

  describe "__using__" do
    test "it routes the call to the test client when testing" do
      {:ok, result} = TestApiConsumer.test
      assert %{body: "ok", status_code: 200} = result
    end

    test "it routes the call to the live client when not testing" do
      with_mock HTTPoison, [get: fn("http://example.com", %{}) -> "<html></html>" end] do
        LiveApiConsumer.test
        assert called HTTPoison.get("http://example.com", %{})
      end
    end
  end
end

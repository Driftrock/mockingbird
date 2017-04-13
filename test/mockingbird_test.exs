defmodule MockingbirdTest do
  use ExUnit.Case

  import Mock

  defmodule MockHttpClient do
    import Mockingbird.Client

    def call(_verb, _url) do
      respond :ok, 200, "ok"
    end
  end

  defmodule SandboxHttpClient do
    import Mockingbird.Client

    def call(_verb, _url) do
      respond :ok, 200, "sandbox responding ok"
    end
  end

  defmodule TestConsumer do
    use Mockingbird, test: MockHttpClient

    def test do
      http_client().call(:get, "http://example.com")
    end
  end

  defmodule EnvironmentAwareConsumer do
    use Mockingbird, test: MockHttpClient, dev: SandboxHttpClient

    def test do
      http_client().call(:get, "http://example.com")
    end
  end

  defmodule MixConfigConsumer do
    use Mockingbird, client: MockHttpClient

    def test do
      http_client().call(:get, "http://example.com")
    end
  end

  defmodule UnsetMixConfigConsumer do
    use Mockingbird, client: nil

    def test do
      http_client().call(:get, "http://example.com")
    end
  end

  describe "__using__" do
    test "it routes the call to the test client when testing" do
      {:ok, result} = TestConsumer.test
      assert %{body: "ok", status_code: 200} = result
    end

    test "it goes through the live client in a `with_live_client` block" do
      with_mock HTTPoison, [get: fn("http://example.com", %{}) -> "<html></html>" end] do
        TestConsumer.with_client :prod, do: fn ->
          TestConsumer.test
        end
        assert called HTTPoison.get("http://example.com", %{})
      end
    end

    test "it uses the right client when switching environments" do
      with_mock Mix, [env: fn -> :dev end] do
        {:ok, res} = EnvironmentAwareConsumer.test
        assert res.body == "sandbox responding ok"
      end

      with_mock Mix, [env: fn -> :test end] do
        {:ok, res} = EnvironmentAwareConsumer.test
        assert res.body == "ok"
      end
    end

    test "it uses the selected client" do
      {:ok, res} = MixConfigConsumer.test
      assert res.body == "ok"
    end

    test "it defaults to the live client" do
      with_mock HTTPoison, [get: fn("http://example.com", %{}) -> "<html></html>" end] do
        UnsetMixConfigConsumer.test
        assert called HTTPoison.get("http://example.com", %{})
      end
    end
  end
end

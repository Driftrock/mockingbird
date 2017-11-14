defmodule Mockingbird.HTTPoisonHttpClientTest do
  use ExUnit.Case

  import Mock

  describe "Mockingbird.HTTPoisonHttpClient.call/4" do
    test "the get call accepts a map that will be expanded into the query stirng" do
      with_mock HTTPoison, get: fn "http://example.com?test=true", %{}, [] -> "<html></html>" end do
        Mockingbird.HTTPoisonHttpClient.call(:get, "http://example.com", %{test: true})
        assert called(HTTPoison.get("http://example.com?test=true", %{}, []))
      end
    end

    test "the get call uses the provided querystring" do
      with_mock HTTPoison, get: fn "http://example.com?test=true", %{}, [] -> "<html></html>" end do
        Mockingbird.HTTPoisonHttpClient.call(:get, "http://example.com?test=true")
        assert called(HTTPoison.get("http://example.com?test=true", %{}, []))
      end
    end

    test "the get call uses the provided hackney options" do
      ssl_options = [ssl: [{:versions, [:"tlsv1.2"]}]]

      with_mock HTTPoison,
        get: fn "http://example.com?test=true", [], ^ssl_options ->
          "<html></html>"
        end do
        Mockingbird.HTTPoisonHttpClient.call(
          :get,
          "http://example.com?test=true",
          %{},
          [],
          ssl_options
        )

        assert called(HTTPoison.get("http://example.com?test=true", [], ssl_options))
      end
    end
  end
end

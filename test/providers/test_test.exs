defmodule Providers.TestTest do
  use ExUnit.Case

  import Mox

  alias Papelillo.Providers.Test

  setup :set_mox_global
  setup :verify_on_exit!

  @config [
    provider: Papelillo.Providers.Test,
    api_key: nil,
    domain: "mydomain.xyz",
    base_url: "https://mailingprovider.xyz/v3",
    test_http_client: HTTPoisonMock
  ]

  @config_mock [
    provider: Papelillo.Providers.Test,
    api_key: nil,
    domain: "mydomain.xyz",
    base_url: "https://mailingprovider.xyz/v3"
  ]

  describe "Create mailing list" do
    test "with correct params" do
      expect(HTTPoisonMock, :post, 1, fn _url, _body, _headers, _opts ->
        Papelillo.Stub.Providers.HttpClient.okCreated()
      end)

      assert {:ok, "List created"} = Test.create("name", "description", "address", @config)
    end

    test "with correct params, testing mock" do
      assert {:ok, "List created"} = Test.create("name", "description", "address", @config_mock)
    end
  end

  describe "Delete mailing list" do
    test "with correct params" do
      expect(HTTPoisonMock, :delete, 1, fn _url, _headers, _opts ->
        Papelillo.Stub.Providers.HttpClient.okDeleted()
      end)

      assert {:ok, "List deleted"} = Test.delete("address", @config)
    end

    test "with correct params, testing mock" do
      assert {:ok, "List deleted"} = Test.delete("address", @config_mock)
    end
  end

  describe "Update mailing list" do
    test "with correct params" do
      expect(HTTPoisonMock, :put, 1, fn _url, _body, _headers, _opts ->
        Papelillo.Stub.Providers.HttpClient.okUpdated()
      end)

      assert {:ok, "List updated"} =
               Test.update("name", "description", "address", "actual_address", @config)
    end

    test "with correct params, testing mock" do
      assert {:ok, "List updated"} =
               Test.update("name", "description", "address", "actual_address", @config_mock)
    end
  end

  describe "Subscribe to mailing list" do
    test "with correct params" do
      expect(HTTPoisonMock, :post, 1, fn _url, _body, _headers, _opts ->
        Papelillo.Stub.Providers.HttpClient.okSubscribed()
      end)

      assert {:ok, "Member subscribed"} = Test.subscribe("list_name", "member", @config)
    end

    test "with correct params, testing mock" do
      assert {:ok, "Member subscribed"} = Test.subscribe("list_name", "member", @config_mock)
    end
  end

  describe "Unsubscribe to mailing list" do
    test "with correct params" do
      expect(HTTPoisonMock, :delete, 1, fn _url, _headers, _opts ->
        Papelillo.Stub.Providers.HttpClient.okUnsubscribed()
      end)

      assert {:ok, "Member unsubscribed"} = Test.unsubscribe("list_name", "member", @config)
    end

    test "with correct params, testing mock" do
      assert {:ok, "Member unsubscribed"} = Test.unsubscribe("list_name", "member", @config_mock)
    end
  end
end

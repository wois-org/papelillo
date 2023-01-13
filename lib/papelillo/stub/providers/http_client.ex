defmodule Papelillo.Stub.Providers.HttpClient do
  def okCreated() do
    {:ok, %HTTPoison.Response{status_code: 200, body: "List created"}}
  end

  def okUpdated() do
    {:ok, %HTTPoison.Response{status_code: 200, body: "List updated"}}
  end

  def okDeleted() do
    {:ok, %HTTPoison.Response{status_code: 200, body: "List deleted"}}
  end

  def okSubscribed() do
    {:ok, %HTTPoison.Response{status_code: 200, body: "Member subscribed"}}
  end

  def okUnsubscribed() do
    {:ok, %HTTPoison.Response{status_code: 200, body: "Member unsubscribed"}}
  end

  def error() do
  end
end

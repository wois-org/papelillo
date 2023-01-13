defmodule Papelillo.Mocks.HttpMock do
  alias Papelillo.Stub.Providers.HttpClient

  def post(url, _body, _headers, _auth) do
    if url =~ "/members" do
      HttpClient.okSubscribed()
    else
      HttpClient.okCreated()
    end
  end

  def put(_url, _body, _headers, _auth) do
    HttpClient.okUpdated()
  end

  def delete(url, _headers, _auth) do
    if url =~ "/members" do
      HttpClient.okUnsubscribed()
    else
      HttpClient.okDeleted()
    end
  end
end

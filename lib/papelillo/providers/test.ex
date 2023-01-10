defmodule Papelillo.Providers.Test do
  @behaviour Papelillo.MailingListBehaviour

  def create(name, description, address, config) do
    body =
      URI.encode_query(%{
        "address" => address,
        "description" => description,
        "name" => name
      })

    do_post(%{body: body, path: "/lists"}, config)
    |> parse()
  end

  def do_post(%{body: body, path: path}, config) do
    http_client =
      Keyword.fetch(config, :test_http_client)
      |> case do
        {:ok, test_http_client} -> test_http_client
        :error -> Papelillo.Mocks.HttpMock
      end

    auth = [hackney: [basic_auth: {"api", "#{Keyword.fetch!(config, :api_key)}"}]]

    base_url = Keyword.fetch!(config, :base_url)
    url = base_url <> path

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    http_client.post(url, body, headers, auth)
  end

  def delete(address, config) do
    do_delete(%{address: address, path: "/lists"}, config)
    |> parse()
  end

  def do_delete(%{address: address, path: path}, config) do
    http_client =
      Keyword.fetch(config, :test_http_client)
      |> case do
        {:ok, test_http_client} -> test_http_client
        :error -> Papelillo.Mocks.HttpMock
      end

    auth = [hackney: [basic_auth: {"api", "#{Keyword.fetch!(config, :api_key)}"}]]

    base_url = Keyword.fetch!(config, :base_url)
    url = base_url <> path <> "/#{address}"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    http_client.delete(url, headers, auth)
  end

  def update(name, description, address, actual_address, config) do
    body =
      URI.encode_query(%{
        "address" => address,
        "description" => description,
        "name" => name
      })

    do_put(%{body: body, path: "/lists", address: actual_address}, config)
    |> parse()
  end

  def do_put(%{address: address, body: body, path: path}, config) do
    http_client =
      Keyword.fetch(config, :test_http_client)
      |> case do
        {:ok, test_http_client} -> test_http_client
        :error -> Papelillo.Mocks.HttpMock
      end

    base_url = Keyword.fetch!(config, :base_url)
    url = base_url <> path <> "/#{address}"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    auth = [hackney: [basic_auth: {"api", "#{Keyword.fetch!(config, :api_key)}"}]]

    http_client.put(url, body, headers, auth)
  end

  def subscribe(list_name, member, config) do
    path = "/lists/#{list_name}/members"

    body =
      URI.encode_query(%{
        "address" => member
      })

    do_post(%{body: body, path: path}, config)
    |> parse()
  end

  def unsubscribe(list_name, member, config) do
    path = "/lists/#{list_name}/members"

    do_delete(%{path: path, address: member}, config)
    |> parse()
  end

  def parse({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  def parse({:ok, %HTTPoison.Response{status_code: 400, body: body}}) do
    {:error, %{error: :error, message: body}}
  end

  def parse({:ok, %HTTPoison.Response{status_code: 404, body: body}}) do
    {:error, %{error: :error, status_code: 404, message: body}}
  end

  def parse({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end

defmodule Papelillo.Providers.Mailgun do
  @behaviour Papelillo.MailingListBehaviour

  def create(nil, _description, _address, _config) do
    {:error, "[#{inspect(__MODULE__)}.create/4] Name is required"}
  end

  def create(_name, _description, nil, _config) do
    {:error, "[#{inspect(__MODULE__)}.create/4] Address is required"}
  end

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
      Keyword.fetch(config, :http_client)
      |> case do
        {:ok, http_client} -> http_client
        :error -> HTTPoison
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

  def delete(nil, _config) do
    {:error, "[#{inspect(__MODULE__)}.delete/2] Address is required"}
  end

  def delete(address, config) do
    do_delete(%{address: address, path: "/lists"}, config)
    |> parse()
  end

  def do_delete(%{address: address, path: path}, config) do
    http_client =
      Keyword.fetch(config, :http_client)
      |> case do
        {:ok, http_client} -> http_client
        :error -> HTTPoison
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

  def update(nil, _description, _address, _actual_address, _config) do
    {:error, "[#{inspect(__MODULE__)}.update/5] Name is required"}
  end

  def update(_name, _description, nil, _actual_address, _config) do
    {:error, "[#{inspect(__MODULE__)}.update/5] Address is required"}
  end

  def update(_name, _description, _address, nil, _config) do
    {:error, "[#{inspect(__MODULE__)}.update/5] Actual Address is required"}
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
      Keyword.fetch(config, :http_client)
      |> case do
        {:ok, http_client} -> http_client
        :error -> HTTPoison
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

  def subscribe(nil, _member, _config) do
    {:error, "[#{inspect(__MODULE__)}.subscribe/3] list_name is required"}
  end

  def subscribe(_list_name, nil, _config) do
    {:error, "[#{inspect(__MODULE__)}.subscribe/3] Member is required"}
  end

  def subscribe(list_name, member, config) do
    path = "/lists/#{list_name}/members"

    body =
      URI.encode_query(%{
        "address" => member,
        "upsert" => "yes"
      })

    do_post(%{body: body, path: path}, config)
    |> parse()
  end

  def unsubscribe(nil, _member, _config) do
    {:error, "[#{inspect(__MODULE__)}.unsubscribe/3] list_name is required"}
  end

  def unsubscribe(_list_name, nil, _config) do
    {:error, "[#{inspect(__MODULE__)}.unsubscribe/3] Member is required"}
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

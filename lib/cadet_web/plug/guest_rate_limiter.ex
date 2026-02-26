defmodule CadetWeb.Plugs.GuestRateLimiter do
  @moduledoc """
  IP-based rate limiting for guest chat requests (20 req/IP/24h).
  """
  import Plug.Conn
  require Logger

  @rate_limit 50
  @period 86_400_000

  def rate_limit, do: @rate_limit

  def init(default), do: default

  def call(conn, _opts) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    key = "guest:#{ip}"

    case ExRated.check_rate(key, @period, @rate_limit) do
      {:ok, _count} ->
        conn

      {:error, limit} ->
        Logger.warning("Guest rate limit of #{limit} exceeded for IP #{ip}")

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:too_many_requests, Jason.encode!(body))
        |> halt()
    end
  end
end

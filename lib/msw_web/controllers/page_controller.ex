defmodule MswWeb.PageController do
  use MswWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end

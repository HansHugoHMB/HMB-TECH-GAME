defmodule WordGameWeb.PageController do
  use WordGameWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end

defmodule WordGameWeb.CoreComponents do
  use Phoenix.Component

  # Exemple de composant générique
  def hello(assigns) do
    ~H"""
    <h1>Hello <%= @name %></h1>
    """
  end
end
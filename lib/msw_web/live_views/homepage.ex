defmodule MswWeb.Liveviews.Homepage do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        all_episodes: Msw.DB.fetch_all(:episodes),
        all_seasons: Msw.DB.fetch_all(:seasons)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    Hello live view!
    <ul :for={{id, n} <- @all_seasons}>
      <li>Season <%= n %> (id <%= id %>)</li>
    </ul>
    <hr>
    <ul :for={{_id, n, title, _plot, _poster, season_id} <- @all_episodes}>
      <li>e<%= n %>s<%= season_id %> - <%= title %></li>
    </ul>
    """
  end
end

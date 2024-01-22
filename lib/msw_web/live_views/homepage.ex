defmodule MswWeb.Liveviews.Homepage do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        all_episodes: Msw.fetch_all(:episodes),
        all_seasons: Msw.fetch_all(:seasons)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    Hello live view!
    <ul :for={{id, n, _, _, _} <- @all_seasons}>
      <li>Season <%= n %> (id <%= id %>)</li>
    </ul>
    <hr>
    <ul :for={{_id, n, _, title, _plot, _poster, season_id, _, _} = r <- @all_episodes}>
      <li>e<%= n %>s<%= season_id %> - <%= title %></li>
    </ul>
    """
  end
end

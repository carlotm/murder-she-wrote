defmodule MswWeb.Liveviews.Episodes do
  use Phoenix.LiveView

  use Phoenix.VerifiedRoutes,
    endpoint: MswWeb.Endpoint,
    router: MswWeb.Router

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filters: %{
          q: "",
          seasons: []
        },
        all_seasons: Msw.DB.fetch_all(:seasons),
        filtered: Msw.DB.fetch_all(:episodes),
        killer: nil,
        loading: true
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <MswWeb.Components.filters
      loading={@loading}
      seasons={@all_seasons}
      selected_seasons={@filters.seasons}
      q={@filters.q}
    />
    <section class="Episodes">
      <MswWeb.Components.episode
        :for={{id, n, t, pl, po, sid} <- @filtered}
        id={id}
        title={t}
        poster={po}
        plot={pl}
        number={n}
        season_id={sid}
        killer={@killer}
      />
    </section>
    """
  end

  def handle_params(%{"q" => q, "seasons" => seasons}, _, socket) do
    filters = %{q: q, seasons: seasons}
    {:noreply, assign(socket, filters: filters, filtered: Msw.DB.filter_episodes(filters), loading: false)}
  end

  def handle_params(_, _, socket), do: {:noreply, assign(socket, loading: false)}

  def handle_event("filter", %{"q" => "", "seasons" => ""}, socket) do
    {:noreply, push_patch(socket, to: "/")}
  end

  def handle_event("filter", %{"q" => q, "seasons" => seasons}, socket) do
    filters = %{q: q, seasons: seasons}

    {:noreply,
     socket
     |> assign(filters: filters, filtered: Msw.DB.filter_episodes(filters), loading: false)
     |> push_patch(to: ~p"/?#{filters}")}
  end

  def handle_event("reveal", %{"value" => episode_id}, socket) do
    {:noreply, assign(socket, killer: Msw.DB.killer_of(episode_id))}
  end

  def handle_event("unreveal", _, socket) do
    {:noreply, assign(socket, killer: nil)}
  end
end

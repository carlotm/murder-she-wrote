defmodule MswWeb.Liveviews.Homepage do
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
        loading: false
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
        :for={{_id, n, t, pl, po, sid} <- @filtered}
        title={t}
        poster={po}
        plot={pl}
        number={n}
        season_id={sid}
      />
    </section>
    """
  end

  def handle_params(%{"q" => q, "seasons" => [""]}, _, socket) do
    filters = %{q: q, seasons: [""]}
    send(self(), {:filter, filters})
    {:noreply, assign(socket, filters: filters, loading: true)}
  end

  def handle_params(%{"q" => q, "seasons" => seasons}, _, socket) do
    filters = %{q: q, seasons: String.split(seasons, ",")}
    send(self(), {:filter, filters})
    {:noreply, assign(socket, filters: filters, loading: true)}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  def handle_event("filter", %{"q" => "", "seasons" => ""}, socket) do
    {:noreply, push_patch(socket, to: "/")}
  end

  def handle_event("filter", %{"q" => q, "seasons" => seasons}, socket) do
    filters = %{q: q, seasons: seasons}
    send(self(), {:filter, filters})
    socket = assign(socket, filters: filters, loading: true)
    qs = %{q: q, seasons: Enum.join(tl(seasons), ",")}
    {:noreply, push_patch(socket, to: ~p"/?#{qs}")}
  end

  def handle_info({:filter, filters}, socket) do
    {:noreply,
     assign(socket,
       filtered: Msw.DB.filter(:episodes, filters),
       loading: false
     )}
  end
end

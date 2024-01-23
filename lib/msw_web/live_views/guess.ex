defmodule MswWeb.Liveviews.Guess do
  use Phoenix.LiveView

  use Phoenix.VerifiedRoutes,
    endpoint: MswWeb.Endpoint,
    router: MswWeb.Router

  def mount(_params, _session, socket) do
    if connected?(socket) do
      [{episode_id, number, title, plot, poster, season_id}] = Msw.DB.random(:episodes)
      killer = Msw.DB.killer_of(episode_id)

      {:ok,
       socket
       |> assign(
         episode_id: episode_id,
         number: number,
         title: title,
         plot: plot,
         poster: poster,
         season_id: season_id,
         killers: [killer | Msw.DB.random(:killers, 3)] |> Enum.shuffle(),
         guess: nil
       )}
    else
      {:ok, socket |> assign(episode_id: nil, guess: nil)}
    end
  end

  def handle_event("guessed", %{"guessed" => killer_id, "episode" => eid}, socket) do
    episode_id = Msw.DB.lookup(:killers, killer_id, 3)
    IO.inspect({episode_id, eid})
    # {:noreply, assign(socket, :guess, "#{guessed.episode_id}" == eid)}
    {:noreply, socket}
  end

  def handle_event("again", %{"value" => "guess"}, socket) do
    # {:noreply, assign(socket, :guess, nil)}
    {:noreply, socket}
  end

  def handle_event("again", %{"value" => "reset"}, socket) do
    # {:noreply, assign(socket, random_episode_and_killers())}
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="GuessEpisode">
      <%= if @episode_id do %>
        <h3 class="GuessEpisode-title">Guess the killer of this episode!</h3>
        <MswWeb.Components.episode
          id={@episode_id}
          title={@title}
          poster={@poster}
          plot={@plot}
          number={@number}
          season_id={@season_id}
          revealable={false}
        />
        <MswWeb.Components.killer_chooser killers={@killers} guess={@guess} />
        <p class="GuessEpisode-study">
          Let's study! <.link navigate={~p"/"}>Browse the episodes</.link>
        </p>
      <% else %>
        <div class="Spinner" />
      <% end %>
    </section>
    """
  end
end

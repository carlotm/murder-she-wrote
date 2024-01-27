defmodule MswWeb.Liveviews.Guess do
  use Phoenix.LiveView

  use Phoenix.VerifiedRoutes,
    endpoint: MswWeb.Endpoint,
    router: MswWeb.Router

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, assign_random_episode_and_killers(socket)}
    else
      {:ok, socket |> assign(episode: nil, guess: nil)}
    end
  end

  def handle_event("guessed", %{"guessed" => killer_id, "episode" => episode_id}, socket) do
    {:noreply, assign(socket, :guess, episode_id == killer_id)}
  end

  def handle_event("again", %{"value" => "guess"}, socket) do
    {:noreply, assign(socket, :guess, nil)}
  end

  def handle_event("again", %{"value" => "reset"}, socket) do
    {:noreply, assign_random_episode_and_killers(socket)}
  end

  def render(assigns) do
    ~H"""
    <section class="GuessEpisode">
      <%= if @episode do %>
        <h3 class="GuessEpisode-title">Guess the killer of this episode!</h3>
        <MswWeb.Components.episode episode={@episode} revealable={false} />
        <MswWeb.Components.killer_chooser killers={@killers} guess={@guess} for={@episode} />
        <p class="GuessEpisode-study">
          Let's study! <.link navigate={~p"/"}>Browse the episodes</.link>
        </p>
      <% else %>
        <div class="Spinner" />
      <% end %>
    </section>
    """
  end

  defp assign_random_episode_and_killers(socket) do
    [{_, episode}] = Msw.DB.random(Msw.Episode)
    killer = Msw.DB.killer_of(episode.ref)

    assign(
      socket,
      episode: episode,
      killers: [killer | Msw.DB.random(Msw.Killer, 3)] |> Enum.shuffle(),
      guess: nil
    )
  end
end

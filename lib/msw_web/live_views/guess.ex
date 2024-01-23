defmodule MswWeb.Liveviews.Guess do
  use Phoenix.LiveView

  use Phoenix.VerifiedRoutes,
    endpoint: MswWeb.Endpoint,
    router: MswWeb.Router

  def mount(_params, _session, socket) do
    if connected?(socket) do
      [{episode_id, number, title, plot, poster, season_id}] = Msw.DB.random(:episodes)
      killer = Msw.DB.killer_of(number)

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
        <MswWeb.Components.killer_chooser
          killers={@killers}
          guess={@guess}
        />
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

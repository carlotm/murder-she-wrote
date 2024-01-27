defmodule MswWeb.Components do
  @moduledoc false
  use Phoenix.Component

  attr :episode, Msw.Episode, required: true
  attr :killer, Msw.Killer, default: nil
  attr :revealable, :boolean, default: true

  def episode(%{episode: episode, killer: killer} = assigns) do
    assigns =
      assign(assigns,
        killer_revealed: false,
        bg_url: "background-image: url(/images/covers/#{episode.poster})",
        killer_revealed: killer != nil and killer.episode_ref == episode.ref
      )

    ~H"""
    <article
      id={@episode.id}
      class={[
        "Episode",
        @killer_revealed && "Episode-reveal"
      ]}
    >
      <div class="Episode-front">
        <div :if={@episode.poster} class="Episode-poster" style={@bg_url} />
        <header>
          <h2 class="Episode-title"><%= @episode.title %></h2>
        </header>
        <section>
          <input
            id={"#{@episode.id}-plot"}
            type="checkbox"
            title="Toggle plot visibility"
            class="Episode-plot_toggler"
          />
          <label for={"#{@episode.id}-plot"} class="Episode-plot_label">
            Plot
          </label>
          <p class="Episode-plot"><%= @episode.plot %></p>
        </section>
        <footer class="Episode-foot">
          <p>Season <%= @episode.season_id %></p>
          <p>Episode <%= @episode.number %></p>
        </footer>
        <aside :if={@revealable} class="Episode-cta">
          <button phx-click="reveal" value={@episode.ref}>Reveal Killer</button>
        </aside>
      </div>
      <div :if={@revealable} class="Episode-back Episode-killer">
        <%= if @killer_revealed do %>
          <img
            src={"data:image/jpeg;base64,#{@killer.picture64}"}
            title={@killer.name}
            alt={@killer.name}
            class="Episode-killer_image"
          />
          <p class="Episode-killer_name"><%= @killer.name %></p>
          <button class="Episode-killer_unreveal" phx-click="unreveal">hide</button>
        <% end %>
      </div>
    </article>
    """
  end

  attr :loading, :boolean, default: false
  attr :q, :string, default: ""
  attr :seasons, :list, default: []
  attr :selected_seasons, :list, default: []

  def filters(assigns) do
    ~H"""
    <section class="Filters">
      <.link navigate="/guess" class="LinkGuess">
        <span>Guess</span>
        <span>the</span>
        <span>killer</span>
      </.link>
      <form id="Filters-form" phx-change="filter">
        <div class="Filter">
          <label class="Filter-name" for="q">
            Filter episodes by title
          </label>
          <input
            id="q"
            name="q"
            type="text"
            placeholder="Word..."
            value={@q}
            autocomplete="off"
            phx-debounce="200"
          />
        </div>
        <div class="Filter">
          <h3 class="Filter-name">Filter episodes by season</h3>
          <input type="hidden" value="" name="seasons[]" />
          <%= for {_, %{number: number}} <- @seasons do %>
            <input
              type="checkbox"
              name="seasons[]"
              id={"s#{number}"}
              value={number}
              checked={"#{number}" in @selected_seasons}
            />
            <label for={"s#{number}"}><%= number %></label>
          <% end %>
        </div>
      </form>
      <%= if @loading do %>
        <section class="Spinner"></section>
      <% end %>
    </section>
    """
  end

  attr :killers, :list, default: []
  attr :guess, :boolean, default: nil
  attr :for, Msw.Episode, default: nil

  def killer_chooser(assigns) do
    ~H"""
    <form class="KillerChooser" phx-change="guessed">
      <.killer_guess_result active={@guess == false} />
      <.killer_guess_result
        bg="success.gif"
        active={@guess == true}
        cta_value="reset"
        cta_label="Try another episode"
        message="Bingo!"
      />
      <label :for={{id, killer} <- @killers} for={"k#{id}"}>
        <div
          class="KillerChooser-picture"
          style={"background-image: url('data:image/jpeg;base64,#{killer.picture64}')"}
        />
        <span class="KillerChooser-text"><%= killer.name %></span>
        <input id={"k#{id}"} name="guessed" value={id} type="radio" />
      </label>
      <input type="hidden" value={@for.ref} name="episode" />
    </form>
    """
  end

  attr :active, :boolean, default: false
  attr :message, :string, default: "Nope"
  attr :cta_value, :string, default: "guess"
  attr :cta_label, :string, default: "Guess again"
  attr :bg, :string, default: "fail.gif"

  def killer_guess_result(assigns) do
    ~H"""
    <div
      class="KillerChooser-panel"
      style={"background-image: url('/images/#{@bg}')"}
      data-active={@active}
    >
      <p><%= @message %></p>
      <button phx-click="again" value={@cta_value} type="button">
        <%= @cta_label %>
      </button>
    </div>
    """
  end
end

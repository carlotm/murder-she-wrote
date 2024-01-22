defmodule MswWeb.Components do
  @moduledoc false
  use Phoenix.Component

  attr :title, :string, default: ""
  attr :plot, :string, default: ""
  attr :poster, :string, default: nil
  attr :number, :integer, default: 1
  attr :season_id, :integer, default: 1

  def episode(%{poster: poster, season_id: season_id, number: number} = assigns) do
    assigns =
      assign(assigns,
        bg_url: "/images/covers/#{poster}",
        episode_id: "s#{season_id}e#{number}"
      )

    ~H"""
    <article id={@episode_id} class="Episode">
      <div class="Episode-front">
        <div :if={@poster} class="Episode-poster" style={"background-image: url(#{@bg_url});"} />
        <header>
          <h2 class="Episode-title"><%= @title %></h2>
        </header>
        <section>
          <input
            id={"#{@episode_id}-plot"}
            type="checkbox"
            title="Toggle plot visibility"
            class="Episode-plot_toggler"
          />
          <label for={"#{@episode_id}-plot"} class="Episode-plot_label">
            Plot
          </label>
          <p class="Episode-plot"><%= @plot %></p>
        </section>
        <footer class="Episode-foot">
          <p>Season <%= @season_id %></p>
          <p>Episode <%= @number %></p>
        </footer>
      </div>
    </article>
    """
  end

  attr :loading, :boolean, default: :false
  attr :q, :string, default: ""
  attr :seasons, :list, default: []
  attr :selected_seasons, :list, default: []

  def filters(assigns) do
    ~H"""
    <section class="Filters">
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
          <input type="hidden" value="" name="seasons[]">
          <%= for {_, number} <- @seasons do %>
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
end

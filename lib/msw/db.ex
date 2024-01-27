defmodule Msw.DB do
  use GenServer

  @name __MODULE__
  @resources [Msw.Episode, Msw.Killer, Msw.Season]

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    state = Enum.map(@resources, &:ets.new(&1, [:ordered_set, :protected, :named_table]))
    {:ok, state, {:continue, :load}}
  end

  def fetch_all(table) do
    :ets.tab2list(table)
  end

  def filter_episodes(filters \\ %{}) do
    Msw.Episode
    |> :ets.tab2list()
    |> Enum.filter(fn {_id, episode} ->
      by_season(filters, episode.season_id) and by_title(filters, episode.title)
    end)
  end

  def random(table, n \\ 1) do
    table
    |> :ets.tab2list()
    |> Enum.take_random(n)
  end

  def killer_of(ref) do
    [killer] = :ets.lookup(Msw.Killer, ref)
    killer
  end

  #
  # Private
  #

  def handle_continue(:load, tables) do
    Enum.each(tables, &load/1)
    {:noreply, tables}
  end

  defp load(resource) do
    Application.app_dir(:msw, "priv/data/#{resource.csv_name}")
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&resource.decode/1)
    |> then(&:ets.insert(resource, &1))
  end

  defp norm(q), do: q |> String.trim() |> String.downcase()

  defp by_season(%{seasons: seasons}, id) do
    seasons == [""] or id in seasons
  end

  defp by_title(%{q: q}, title) do
    norm(q) == "" or norm(title) =~ norm(q)
  end
end

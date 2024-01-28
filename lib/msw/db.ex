defmodule Msw.DB do
  use GenServer

  @name __MODULE__
  @resources [Msw.Episode, Msw.Killer, Msw.Season]

  def start_link(_),
    do: GenServer.start_link(__MODULE__, [], name: @name)

  def fetch_all(table),
    do: GenServer.call(@name, {:fetch_all, table})

  def filter_episodes(filters \\ %{}),
    do: GenServer.call(@name, {:filter, filters})

  def random(table, n \\ 1),
    do: GenServer.call(@name, {:rand, table, n})

  def killer_of(ref),
    do: GenServer.call(@name, {:killer_of, ref})

  #
  # Private
  #

  @impl true
  def init(_) do
    state = Enum.map(@resources, &:ets.new(&1, [:ordered_set, :protected, :named_table]))
    {:ok, state, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, tables) do
    Enum.each(tables, &load/1)
    {:noreply, tables}
  end

  @impl true
  def handle_call({:fetch_all, table}, _from, state),
    do: {:reply, :ets.tab2list(table), state}

  def handle_call({:rand, table, n}, _from, state) do
    rand =
      table
      |> :ets.tab2list()
      |> Enum.take_random(n)

    {:reply, rand, state}
  end

  def handle_call({:filter, filters}, _from, state) do
    filtered =
      Msw.Episode
      |> :ets.tab2list()
      |> Enum.filter(fn {_id, episode} ->
        by_season(filters, episode.season_id) and by_title(filters, episode.title)
      end)

    {:reply, filtered, state}
  end

  def handle_call({:killer_of, ref}, _from, state) do
    [killer] = :ets.lookup(Msw.Killer, ref)
    {:reply, killer, state}
  end

  defp load(resource) do
    Application.app_dir(:msw, "priv/data/#{resource.csv_name}")
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&resource.decode/1)
    |> then(&:ets.insert(resource, &1))
  end

  defp norm(q),
    do: q |> String.trim() |> String.downcase()

  defp by_season(%{seasons: seasons}, id),
    do: seasons == [""] or id in seasons

  defp by_title(%{q: q}, title),
    do: norm(q) == "" or norm(title) =~ norm(q)
end

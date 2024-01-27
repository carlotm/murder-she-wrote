defmodule Msw.DB do
  use GenServer

  @name __MODULE__
  @tables [:seasons, :killers, :episodes]

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    @tables
    |> Enum.each(fn table ->
      :ets.new(table, [:ordered_set, :protected, :named_table])
    end)

    {:ok, @tables, {:continue, :load}}
  end

  def fetch_all(table) do
    :ets.tab2list(table)
  end

  def filter_episodes(filters \\ %{}) do
    :episodes
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
    [killer] = :ets.lookup(:killers, ref)
    killer
  end

  def lookup(table, k, pos \\ -1) when is_binary(k) do
    k = String.to_integer(k)

    case pos do
      -1 -> :ets.lookup(table, k)
      n -> :ets.lookup_element(table, k, n)
    end
  end

  #
  # Private
  #

  def handle_continue(:load, tables) do
    Enum.each(tables, &load/1)
    {:noreply, tables}
  end

  defp load(table) do
    Application.app_dir(:msw, "priv/data/#{Atom.to_string(table)}.csv")
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&csv_row_to_tuple(&1, table))
    |> then(&:ets.insert(table, &1))
  end

  defp csv_row_to_tuple(row, :episodes),
    do: Msw.Episode.decode(row)

  defp csv_row_to_tuple(row, :seasons),
    do: Msw.Season.decode(row)

  defp csv_row_to_tuple(row, :killers),
    do: Msw.Killer.decode(row)

  defp norm(q), do: q |> String.trim() |> String.downcase()

  defp by_season(%{seasons: seasons}, id) do
    seasons == [""] or id in seasons
  end

  defp by_title(%{q: q}, title) do
    norm(q) == "" or norm(title) =~ norm(q)
  end
end

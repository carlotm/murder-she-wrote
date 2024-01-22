defmodule Msw.DB do
  use GenServer

  @name __MODULE__
  @fields_to_int ["id", "episode_id"]
  @data %{
    seasons: ["id", "number"],
    episodes: ["id", "number", "title", "plot", "poster", "season_id"],
    killers: ["id", "name", "episode_id", "picture64"]
  }

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    Enum.each(@data, fn {k, _} ->
      :ets.new(k, [:ordered_set, :protected, :named_table])
    end)

    {:ok, @data, {:continue, :load}}
  end

  def fetch_all(table) do
    :ets.tab2list(table)
  end

  def filter(table, filters \\ %{}) do
    table
    |> :ets.tab2list()
    |> Enum.filter(fn {_id, _number, title, _plot, _poster, season_id} ->
      by_season(filters, season_id) and by_title(filters, title)
    end)
  end

  #
  # Private
  #

  def handle_continue(:load, tables) do
    Enum.each(tables, &load/1)
    {:noreply, tables}
  end

  defp load({table, fields}) do
    Application.app_dir(:msw, "priv/data/#{Atom.to_string(table)}.csv")
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&csv_row_to_tuple(&1, fields))
    |> then(&:ets.insert(table, &1))
  end

  defp csv_row_to_tuple(row, fields) do
    Enum.reduce(fields, {}, fn
      field, acc when field in @fields_to_int ->
        {n, _} = Map.get(row, field) |> Integer.parse()
        Tuple.append(acc, n)

      field, acc ->
        Tuple.append(acc, Map.get(row, field))
    end)
  end

  defp norm(q), do: q |> String.trim() |> String.downcase()

  defp by_season(%{seasons: seasons}, id) do
    seasons == [""] or id in seasons
  end

  defp by_title(%{q: q}, title) do
    norm(q) == "" or norm(title) =~ norm(q)
  end
end

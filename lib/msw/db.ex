defmodule Msw.DB do
  use GenServer

  @name __MODULE__

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    :ets.new(:episodes, [:set, :protected, :named_table])
    :ets.new(:seasons, [:set, :protected, :named_table])
    :ets.new(:killers, [:set, :protected, :named_table])

    {:ok, [:episodes, :seasons, :killers], {:continue, :load}}
  end

  def handle_continue(:load, tables) do
    Enum.each(tables, &load/1)
    {:noreply, tables}
  end

  defp load(k) do
    Application.app_dir(:msw, "priv/data/" <> Atom.to_string(k) <> ".csv")
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.map(&Map.values/1)
    |> Enum.map(&List.to_tuple/1)
    |> then(&:ets.insert(k, &1))
  end
end

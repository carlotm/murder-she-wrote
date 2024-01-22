defmodule Msw do
  @moduledoc false

  def fetch_all(table) do
    :ets.tab2list(table)
  end
end

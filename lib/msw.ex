defmodule Msw do
  @moduledoc false
end

defmodule Msw.Episode do
  @enforce_keys [:id, :title, :poster, :plot, :number, :season_id, :ref]
  defstruct [:id, :title, :poster, :plot, :number, :season_id, :ref]

  def decode(%{
        "title" => title,
        "poster" => poster,
        "plot" => plot,
        "number" => number,
        "season_id" => season_id,
        "id" => ref
      }) do
    episode_id = build_episode_id(number, season_id)
    {episode_id,
     %__MODULE__{
       id: episode_id,
       title: title,
       poster: poster,
       plot: plot,
       number: number,
       season_id: season_id,
       ref: ref
     }}
  end

  defp build_episode_id(number, season) do
    s = String.pad_leading(season, 2, "0")
    e = String.pad_leading(number, 2, "0")
    "s#{s}e#{e}"
  end
end

defmodule Msw.Season do
  @enforce_keys [:id, :number]
  defstruct [:id, :number]

  def decode(%{"number" => number}) do
    int_id = String.to_integer(number)
    {int_id, %__MODULE__{id: number, number: number}}
  end
end

defmodule Msw.Killer do
  @enforce_keys [:name, :picture64, :episode_ref]
  defstruct [:name, :picture64, :episode_ref]

  def decode(%{"name" => name, "picture64" => picture64, "episode_id" => ref}) do
    {ref, %__MODULE__{name: name, picture64: picture64, episode_ref: ref}}
  end
end

defmodule Sas do

  def main(args) do
    opts = args |> parse_args

    name =
    case opts[:name] do
      nil ->
        "SAŠO"
      val ->
         val
    end

    IO.puts ["Looking for => ", name]

    graduate name
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [name: :string]
    )
    options
  end

  def graduate(nemo) do
    response = HTTPotion.get "http://feri.um.si"
    html = response.body

    case parse(html, nemo) do
      {:ok, data} ->
        IO.puts "Possible candidates:"
        Enum.each(data, fn(c) -> pretty_print_candidate(c) end)
      :nothing ->
        IO.puts ["No ", nemo, " found :("]
    end
  end

  defp parse(html, who) do
    nodes = Floki.find(html, "article ul.zagovori li")

    {:ok, regex} = Regex.compile(who, "ui")

    candidates = Enum.map(nodes, fn(node) ->
      get_candidate_data(node)
    end)

    result = Enum.filter(candidates, fn(c) ->
      String.match?(c.name, regex)
    end)

    if length(result) > 0 do
      {:ok, result}
    else
      :nothing
    end
  end

  defp get_candidate_data(node) do
    {"li", _, node_data} = node
    [title_node, location_node, candidate_node] = node_data

    {"h3", _, [title]} = title_node
    {"div", _, [location]} = location_node
    {"div", [], [name]} = candidate_node

    %{name: name, title: title, location: location}
  end

  defp pretty_print_candidate(candidate) do
    IO.puts "========================="
    IO.puts "Who   => #{candidate.name}"
    IO.puts "Where => #{candidate.location}"
    IO.puts "What  => #{candidate.title}"
  end


end

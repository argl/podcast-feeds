defmodule PodcastFeeds.Parsers.Helpers do
  use Timex

  defmodule ParserState do
    defstruct feed: nil,      # the feed structure we try to fill
    element_acc: nil,         # accumulates character data
    element_stack: [],        # holds our main element stack (channel, item, etc)
    namespaces: [],           # gobbls up namespace info (usually in xml declaration at the top)
    catstack: [],             # itunes category stack. the not-quite-infinitely-recursive monster
    subcatstack: [],          # see catstack
    level: 0                  # see catstack
  end

  # set the current character content to a struct member
  def map_character_content(state, struct_member, struct_name) do
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state
    case elem.__struct__ do
      ^struct_name ->
        elem = %{elem | struct_member => element_acc}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

  # append the current character content to a list of strings
  def append_character_content_to_list(state, struct_member, struct_name) do
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state
    case elem.__struct__ do
      ^struct_name ->
        elem = %{elem | struct_member => [element_acc | Map.fetch!(elem, struct_member)]}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

  # map attributes to a ... map. ahem.
  def map_attributes(state, attributes, struct_member, struct_name) do
    %ParserState{element_stack: [elem | element_stack]} = state
    case elem.__struct__ do
      ^struct_name ->
        attribute_map = extract_attributes(attributes)
        elem = %{elem | struct_member => attribute_map}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

  # try to parse the current character map to an integer, 
  # set it to nil on failure
  # pass on result via state
  def parse_character_content_to_integer(state) do
    %ParserState{element_acc: element_acc} = state
    element_acc = case Integer.parse(element_acc) do
      {value, _} -> value
      :error -> nil
    end
    %{state | element_acc: element_acc}
  end

  # try to parse the current character acc to a timex date
  # parsing is pretty picky, at the lightest sniff of
  # problems, nil is returned.
  def parse_character_content_to_date(state) do
    %ParserState{element_acc: element_acc} = state
    %{state | element_acc: parse_datetime(element_acc)}
  end

  # parse the value into a date or return nil
  def parse_datetime(text) do
    case text |> DateFormat.parse("{RFC1123}") do
      {:ok, date} -> date
      _ -> nil
    end
  end

  # get attributes from node and put it into a map
  def extract_attributes(attributes) do
    Enum.reduce attributes, %{}, fn({:attribute, key, _, _, value}, acc) -> 
      Map.put(acc, List.to_atom(key), to_string(value))
    end
  end

end
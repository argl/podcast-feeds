defmodule PodcastFeeds.Parsers.RSS2 do

  # use GenServer
  use Timex

  alias PodcastFeeds.Feed
  alias PodcastFeeds.Entry
  alias PodcastFeeds.Meta
  # alias PodcastFeeds.Itunes
  # alias PodcastFeeds.AtomLink
  # alias PodcastFeeds.Psc
  alias PodcastFeeds.Image
  # alias PodcastFeeds.Enclosure
  # alias Timex.DateFormat

  defmodule ParserState do
    defstruct feed: nil,      # the feed structure we try to fill
    element_acc: nil,         # accumulates character data
    # checkout_elem: nil,     # holds a funtion to get our current element we work on
    # checkin_elem: nil,      # holds a function to put our current element back
    element_stack: []         # holds our element stack
    # element_name_stack: []  # holds the curent element name
    # meta: nil,              # meta information on the feed, stuff from the <channel> element
    # entry: nil,             # entry struct, corresponds to the <item> elements of the feed
    # image: nil,       
    # enclosure: nil
  end

  defmodule SkipDays do
    defstruct days: []
  end
  defmodule SkipHours do
    defstruct hours: []
  end

  def parse(stream) do

    :erlsom.parse_sax(
      "", 
      nil, 
      &sax_event_handler/2,
      [{:continuation_function, &continue_stream/2, stream}]
    )
  end

  def continue_stream(tail, stream) do
    case Enum.take(stream, 1) do
      [] -> {tail, Stream.drop(stream, 1)}
      [data] -> {<<tail :: binary, data::binary>>, Stream.drop(stream, 1)}
    end
  end

  defp sax_event_handler(:startDocument, _state) do
    # IO.puts "-> startDocument: #{state}"
    %ParserState{}
  end

  defp sax_event_handler(:endDocument, state) do
    # IO.puts "-> endDocument: #{state}"
    state.feed
  end

  defp sax_event_handler({:startElement, _uri, 'rss', [], _attributes}, state) do
    # state = %{state | element_name_stack: [element_name | element_name_stack] }
    %{state | feed: %Feed{} }
  end
  defp sax_event_handler({:endElement, _uri, 'rss', []}, state) do
    # feed = %{state.feed | entries: entries}
    # %{state | feed: feed}
    state
  end

  defp sax_event_handler({:startElement, _uri, 'channel', [], _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%Meta{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'channel', []}, %ParserState{element_stack: element_stack, feed: feed} = state) do
    [elem | element_stack] = element_stack
    feed = %{feed | meta: elem}
    %{state | element_stack: element_stack, feed: feed}
  end

  defp sax_event_handler({:startElement, _uri, 'item', [], _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%Entry{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'item', []}, %ParserState{element_stack: element_stack, feed: feed} = state) do
    [elem | element_stack] = element_stack
    feed = %{feed | entries: [elem | feed.entries]}
    %{state | element_stack: element_stack, feed: feed}
  end

  #basics on channel and items

  defp sax_event_handler({:startElement, _uri, 'title', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'title', []}, state) do
    state
    |> map_character_content(:title, PodcastFeeds.Meta)
    |> map_character_content(:title, PodcastFeeds.Entry)
  end

  defp sax_event_handler({:startElement, _uri, 'link', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'link', []}, state) do
    state
    |> map_character_content(:link, PodcastFeeds.Meta)
    |> map_character_content(:link, PodcastFeeds.Entry)
  end

  defp sax_event_handler({:startElement, _uri, 'description', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'description', []}, state) do
    state
    |> map_character_content(:description, PodcastFeeds.Meta)
    |> map_character_content(:description, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'author', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'author', []}, state) do
    state
    |> map_character_content(:author, PodcastFeeds.Meta)
    |> map_character_content(:author, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'language', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'language', []}, state) do
    state
    |> map_character_content(:language, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'copyright', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'copyright', []}, state) do
    state
    |> map_character_content(:copyright, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'pubDate', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'pubDate', []}, state) do
    state
    |> parse_character_content_to_date
    |> map_character_content(:publication_date, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'lastBuildDate', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'lastBuildDate', []}, state) do
    state
    |> parse_character_content_to_date
    |> map_character_content(:last_build_date, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'generator', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'generator', []}, state) do
    state
    |> map_character_content(:generator, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'guid', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'guid', []}, state) do
    state
    |> map_character_content(:guid, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'category', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'category', []}, state) do
    state
    |> append_character_content_to_list(:categories, PodcastFeeds.Meta)
    |> append_character_content_to_list(:categories, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'cloud', [], attributes}, state) do
    state
    |> map_attributes(attributes, :cloud, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'ttl', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'ttl', []}, state) do
    state
    |> parse_character_content_to_integer
    |> map_character_content(:ttl, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'managingEditor', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'managingEditor', []}, state) do
    state
    |> map_character_content(:managing_editor, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'webMaster', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'webMaster', []}, state) do
    state
    |> map_character_content(:web_master, PodcastFeeds.Meta)
  end

  # skipHours, sjipDays elements on channel

  defp sax_event_handler({:startElement, _uri, 'skipDays', [], _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%SkipDays{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'skipDays', []}, %ParserState{element_stack: element_stack} = state) do
    [skip_days | element_stack] = element_stack
    [meta | element_stack] = element_stack
    meta = %{meta | skip_days: Enum.reverse(skip_days.days)}
    element_stack = [meta | element_stack]
    %{state | element_stack: element_stack}
  end
  defp sax_event_handler({:startElement, _uri, 'day', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'day', []}, state) do
    state
    |> append_character_content_to_list(:days, PodcastFeeds.Parsers.RSS2.SkipDays)
  end

  defp sax_event_handler({:startElement, _uri, 'skipHours', [], _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%SkipHours{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'skipHours', []}, %ParserState{element_stack: element_stack} = state) do
    [skip_hours | element_stack] = element_stack
    [meta | element_stack] = element_stack
    meta = %{meta | skip_hours: Enum.reverse(skip_hours.hours)}
    element_stack = [meta | element_stack]
    %{state | element_stack: element_stack}
  end
  defp sax_event_handler({:startElement, _uri, 'hour', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'hour', []}, state) do
    state
    |> parse_character_content_to_integer
    |> append_character_content_to_list(:hours, PodcastFeeds.Parsers.RSS2.SkipHours)
  end


  # image element
  defp sax_event_handler({:startElement, _uri, 'image', [], _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%Image{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'image', []}, %ParserState{element_stack: element_stack} = state) do
    [_image | element_stack] = element_stack
    %{state | element_stack: element_stack}
  end





  # fall-through

  defp sax_event_handler({:startElement, _uri, _name, _prefix, _attributes}, state), do: state
  defp sax_event_handler({:endElement, _uri, _name, _prefix}, state), do: state


  # push all chars onto the accumulator
  defp sax_event_handler({:characters, chars}, state) do
    x = "#{state.element_acc}#{chars}"
    %{state | element_acc: x}
  end



  # defp sax_event_handler({:startElement, _uri, _local_name, [], _attributes}, state) do
  #   # IO.puts "-> startElement: #{uri} #{prefix}:#{local_name}"
  #   state
  # end

  # defp sax_event_handler({:endElement, _uri, _local_name, []}, state) do
  #   # IO.puts "-> endElement: #{prefix}:#{local_name}"
  #   state
  # end

  defp sax_event_handler({:processingInstruction, _target, _data}, state) do
    # IO.puts "-> processingInstruction: target=#{target}, data=#{data}"
    state
  end


  defp sax_event_handler({:startPrefixMapping, _prefix, _uri}, state) do
    # IO.puts "-> startPrefixMapping: #{prefix}=#{uri}"
    state
  end

  defp sax_event_handler({:endPrefixMapping, _prefix}, state) do
    # IO.puts "-> endPrefixMapping: #{prefix}"
    state
  end

  defp sax_event_handler({:ignorableWhitespace, _characters}, state) do
    # IO.puts "-> ignorableWhitespace: #{state}: '#{characters}'"
    state
  end


  defp sax_event_handler(:error, description) do
    IO.puts "error: #{description}"
  end

  defp sax_event_handler(:internalError, description) do
    IO.puts "internal error: #{description}"
  end


  # helpers
  # set the current character content to a struct member
  defp map_character_content(state, struct_member, struct_name) do
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state
    case elem.__struct__ do
      ^struct_name ->
        elem = %{elem | struct_member => element_acc}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

  # append the current character content to a list of strings
  defp append_character_content_to_list(state, struct_member, struct_name) do
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state
    case elem.__struct__ do
      ^struct_name ->
        elem = %{elem | struct_member => [element_acc | Map.fetch!(elem, struct_member)]}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

  # map attributes to a ... map. ahem.
  defp map_attributes(state, attributes, struct_member, struct_name) do
    %ParserState{element_stack: [elem | element_stack]} = state
    case elem.__struct__ do
      ^struct_name ->
        attribute_map = Enum.reduce(attributes, %{}, fn({_,key,_,_,value}, acc) -> 
          Map.put(acc, List.to_atom(key), value)
        end)
        elem = %{elem | struct_member => attribute_map}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

  # try to parse the current character map to an integer, 
  # set it to nil on failure
  # pass on result via state
  defp parse_character_content_to_integer(state) do
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
  defp parse_character_content_to_date(state) do
    %ParserState{element_acc: element_acc} = state
    %{state | element_acc: parse_datetime(element_acc)}
  end

  # parse the value into a date or return nil
  defp parse_datetime(text) do
    case text |> DateFormat.parse("{RFC1123}") do
      {:ok, date} -> date
      _ -> nil
    end
  end


end

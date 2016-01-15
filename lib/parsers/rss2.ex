defmodule PodcastFeeds.Parsers.RSS2 do

  # use GenServer
  use Timex

  alias PodcastFeeds.Feed
  alias PodcastFeeds.Entry
  alias PodcastFeeds.Meta
  # alias PodcastFeeds.Itunes
  # alias PodcastFeeds.AtomLink
  # alias PodcastFeeds.Psc
  # alias PodcastFeeds.Image
  # alias PodcastFeeds.Enclosure
  # alias Timex.DateFormat

  defmodule ParserState do
    defstruct feed: nil,    # the feed structure we try to fill
    element_acc: nil,       # accumulates character data
    # checkout_elem: nil,     # holds a funtion to get our current element we work on
    # checkin_elem: nil,      # holds a function to put our current element back
    element_stack: []      # holds our element stack
    # meta: nil,              # meta information on the feed, stuff from the <channel> element
    # entry: nil,             # entry struct, corresponds to the <item> elements of the feed
    # image: nil,       
    # enclosure: nil
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
    %{state | element_acc: nil}
  end

  defp sax_event_handler({:startElement, _uri, 'rss', _prefix, _attributes}, state) do 
    %{state | feed: %Feed{} }
  end
  defp sax_event_handler({:endElement, _uri, 'rss', _prefix}, state) do
    # feed = %{state.feed | entries: entries}
    # %{state | feed: feed}
    state
  end

  defp sax_event_handler({:startElement, _uri, 'channel', _prefix, _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%Meta{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'channel', _prefix}, %ParserState{element_stack: element_stack, feed: feed} = state) do
    [elem | element_stack] = element_stack
    feed = %{feed | meta: elem}
    %{state | element_stack: element_stack, feed: feed}
  end

  defp sax_event_handler({:startElement, _uri, 'item', _prefix, _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%Entry{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'item', _prefix}, %ParserState{element_stack: element_stack, feed: feed} = state) do
    [elem | element_stack] = element_stack
    feed = %{feed | entries: [elem | feed.entries]}
    %{state | element_stack: element_stack, feed: feed}
  end


  defp sax_event_handler({:startElement, _uri, 'title', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'title', _prefix}, state) do
    state
    |> map_character_content(:title, PodcastFeeds.Meta)
    |> map_character_content(:title, PodcastFeeds.Entry)
  end

  defp sax_event_handler({:startElement, _uri, 'link', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'link', _prefix}, state) do
    state
    |> map_character_content(:link, PodcastFeeds.Meta)
    |> map_character_content(:link, PodcastFeeds.Entry)
  end

  defp sax_event_handler({:startElement, _uri, 'description', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'description', _prefix}, state) do
    state
    |> map_character_content(:title, PodcastFeeds.Meta)
    |> map_character_content(:title, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'author', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'author', _prefix}, state) do
    state
    |> map_character_content(:author, PodcastFeeds.Meta)
    |> map_character_content(:author, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'language', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'language', _prefix}, state) do
    state
    |> map_character_content(:language, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'copyright', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'copyright', _prefix}, state) do
    state
    |> map_character_content(:copyright, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'pubDate', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'pubDate', _prefix}, state) do
    state
    |> map_character_content(:publication_date, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'lastBuildDate', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'lastBuildDate', _prefix}, state) do
    state
    |> map_character_content(:last_build_date, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'generator', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'generator', _prefix}, state) do
    state
    |> map_character_content(:generator, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'guid', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'guid', _prefix}, state) do
    state
    |> map_character_content(:guid, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'category', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'category', _prefix}, state) do
    state
    |> append_character_content_to_list(:categories, PodcastFeeds.Meta)
    |> append_character_content_to_list(:categories, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'rating', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'rating', _prefix}, state) do
    state
    |> map_character_content(:rating, PodcastFeeds.Meta)
  end  


  defp sax_event_handler({:startElement, _uri, 'cloud', _prefix, attributes}, state) do
    state
    |> map_attributes(attributes, :cloud, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'ttl', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'ttl', _prefix}, state) do
    state
    |> parse_character_content_to_integer
    |> map_character_content(:ttl, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'managingEditor', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'managingEditor', _prefix}, state) do
    state
    |> map_character_content(:managing_editor, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'webMaster', _prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'webMaster', _prefix}, state) do
    state
    |> map_character_content(:web_master, PodcastFeeds.Meta)
  end





  defp sax_event_handler({:startElement, _uri, _name, _prefix, _attributes}, state), do: state
  defp sax_event_handler({:endElement, _uri, _name, _prefix}, state), do: state


  # push all chars onto the accumulator
  defp sax_event_handler({:characters, chars}, state) do
    x = "#{state.element_acc}#{chars}"
    %{state | element_acc: x}
  end



  # defp sax_event_handler({:startElement, _uri, _local_name, _prefix, _attributes}, state) do
  #   # IO.puts "-> startElement: #{uri} #{prefix}:#{local_name}"
  #   state
  # end

  # defp sax_event_handler({:endElement, _uri, _local_name, _prefix}, state) do
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

  # map attributes to a map
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

end

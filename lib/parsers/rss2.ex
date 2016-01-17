defmodule PodcastFeeds.Parsers.RSS2 do

  # use GenServer
  use Timex

  alias PodcastFeeds.Parsers.Helpers
  alias PodcastFeeds.Parsers.Helpers.ParserState

  alias PodcastFeeds.Feed
  alias PodcastFeeds.Entry
  alias PodcastFeeds.Meta
  alias PodcastFeeds.Itunes
  # alias PodcastFeeds.AtomLink
  # alias PodcastFeeds.Psc
  alias PodcastFeeds.Image
  # alias PodcastFeeds.Enclosure
  # alias Timex.DateFormat
  alias PodcastFeeds.SkipDays
  alias PodcastFeeds.SkipHours



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
    state
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
    |> Helpers.map_character_content(:title, PodcastFeeds.Meta)
    |> Helpers.map_character_content(:title, PodcastFeeds.Entry)
    |> Helpers.map_character_content(:title, PodcastFeeds.Image)
  end

  defp sax_event_handler({:startElement, _uri, 'link', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'link', []}, state) do
    state
    |> Helpers.map_character_content(:link, PodcastFeeds.Meta)
    |> Helpers.map_character_content(:link, PodcastFeeds.Entry)
    |> Helpers.map_character_content(:link, PodcastFeeds.Image)
  end

  defp sax_event_handler({:startElement, _uri, 'description', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'description', []}, state) do
    state
    |> Helpers.map_character_content(:description, PodcastFeeds.Meta)
    |> Helpers.map_character_content(:description, PodcastFeeds.Entry)
    |> Helpers.map_character_content(:description, PodcastFeeds.Image)
  end


  defp sax_event_handler({:startElement, _uri, 'author', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'author', []}, state) do
    state
    |> Helpers.map_character_content(:author, PodcastFeeds.Meta)
    |> Helpers.map_character_content(:author, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'language', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'language', []}, state) do
    state
    |> Helpers.map_character_content(:language, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'copyright', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'copyright', []}, state) do
    state
    |> Helpers.map_character_content(:copyright, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'pubDate', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'pubDate', []}, state) do
    state
    |> Helpers.parse_character_content_to_date
    |> Helpers.map_character_content(:publication_date, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'lastBuildDate', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'lastBuildDate', []}, state) do
    state
    |> Helpers.parse_character_content_to_date
    |> Helpers.map_character_content(:last_build_date, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'generator', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'generator', []}, state) do
    state
    |> Helpers.map_character_content(:generator, PodcastFeeds.Meta)
  end

  defp sax_event_handler({:startElement, _uri, 'guid', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'guid', []}, state) do
    state
    |> Helpers.map_character_content(:guid, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'category', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'category', []}, state) do
    state
    |> Helpers.append_character_content_to_list(:categories, PodcastFeeds.Meta)
    |> Helpers.append_character_content_to_list(:categories, PodcastFeeds.Entry)
  end


  defp sax_event_handler({:startElement, _uri, 'cloud', [], attributes}, state) do
    state
    |> Helpers.map_attributes(attributes, :cloud, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'ttl', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'ttl', []}, state) do
    state
    |> Helpers.parse_character_content_to_integer
    |> Helpers.map_character_content(:ttl, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'managingEditor', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'managingEditor', []}, state) do
    state
    |> Helpers.map_character_content(:managing_editor, PodcastFeeds.Meta)
  end


  defp sax_event_handler({:startElement, _uri, 'webMaster', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'webMaster', []}, state) do
    state
    |> Helpers.map_character_content(:web_master, PodcastFeeds.Meta)
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
    |> Helpers.append_character_content_to_list(:days, PodcastFeeds.SkipDays)
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
    |> Helpers.parse_character_content_to_integer
    |> Helpers.append_character_content_to_list(:hours, PodcastFeeds.SkipHours)
  end


  # image element, title and url nodes handled above
  defp sax_event_handler({:startElement, _uri, 'image', [], _attributes}, %ParserState{element_stack: element_stack} = state) do
    %{state | element_stack: [%Image{} | element_stack]}
  end
  defp sax_event_handler({:endElement, _uri, 'image', []}, %ParserState{element_stack: element_stack} = state) do
    [image | element_stack] = element_stack
    [meta | element_stack] = element_stack
    meta = %{meta | image: image}
    element_stack = [meta | element_stack]
    %{state | element_stack: element_stack}
  end
  defp sax_event_handler({:startElement, _uri, 'url', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'url', []}, state) do
    state
    |> Helpers.map_character_content(:url, PodcastFeeds.Image)
  end
  defp sax_event_handler({:startElement, _uri, 'width', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'width', []}, state) do
    state
    |> Helpers.parse_character_content_to_integer
    |> Helpers.map_character_content(:width, PodcastFeeds.Image)
  end
  defp sax_event_handler({:startElement, _uri, 'height', [], _attributes}, state) do
    %{state | element_acc: ""}
  end
  defp sax_event_handler({:endElement, _uri, 'height', []}, state) do
    state
    |> Helpers.parse_character_content_to_integer
    |> Helpers.map_character_content(:height, PodcastFeeds.Image)
  end

  defp sax_event_handler({:startElement, uri, name, 'atom', attributes}, state) do
    # forward to atom module
    PodcastFeeds.Parsers.Ext.Atom.sax_event_handler({:startElement, uri, name, 'atom', attributes}, state)
  end
  defp sax_event_handler({:endElement, uri, name, 'atom'}, state) do 
    # forward to atom module
    PodcastFeeds.Parsers.Ext.Atom.sax_event_handler({:endElement, uri, name, 'atom'}, state)
  end


  defp sax_event_handler({:startElement, uri, name, 'itunes', attributes}, state) do
    # forward to itunes module
    # make sure we have an itunes element intialized
    # either on meta or entry elements allowed
    [elem | element_stack] = state.element_stack
    elem = case elem.itunes do
      nil -> %{elem | itunes: %Itunes{}}
      _ -> elem
    end
    state = %{state | element_stack: [elem | element_stack]}
    PodcastFeeds.Parsers.Ext.Itunes.sax_event_handler({:startElement, uri, name, 'itunes', attributes}, state)
  end
  defp sax_event_handler({:endElement, uri, name, 'itunes'}, state) do 
    # forward to Itunes module
    PodcastFeeds.Parsers.Ext.Itunes.sax_event_handler({:endElement, uri, name, 'itunes'}, state)
  end


  # fall-through

  defp sax_event_handler({:startElement, _uri, _name, _prefix, _attributes}, state), do: state
  defp sax_event_handler({:endElement, _uri, _name, _prefix}, state), do: state


  # push all chars onto the accumulator
  defp sax_event_handler({:characters, chars}, state) do
    x = "#{state.element_acc}#{chars}"
    %{state | element_acc: x}
  end



  defp sax_event_handler({:processingInstruction, _target, _data}, state) do
    # IO.puts "-> processingInstruction: target=#{target}, data=#{data}"
    state
  end


  defp sax_event_handler({:startPrefixMapping, prefix, uri}, state) do
    #IO.puts "-> startPrefixMapping: #{prefix}=#{uri}"
    namespaces = Keyword.put_new(state.namespaces, List.to_atom(prefix), to_string(uri))
    %{state | namespaces: namespaces}
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



end

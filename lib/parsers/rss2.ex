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
    defstruct feed: nil,
    element_acc: nil,
    meta: nil,
    entry: nil,
    image: nil,
    enclosure: nil
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

  defp sax_event_handler({:startElement, _uri, 'rss', _prefix, _attributes}, state), do: %{state | feed: %Feed{} }
  defp sax_event_handler({:endElement, _uri, 'rss', _prefix}, state) do
    entries = Enum.reverse state.feed.entries
    feed = %{state.feed | entries: entries}
    %{state | feed: feed}
  end

  defp sax_event_handler({:startElement, _uri, 'channel', _prefix, _attributes}, state), do: %{state | meta: %Meta{} }
  defp sax_event_handler({:endElement, _uri, 'channel', _prefix}, state) do
    meta = state.meta
    feed = %{state.feed | meta: meta}
    %{state | meta: nil, feed: feed }
  end

  defp sax_event_handler({:startElement, _uri, 'item', _prefix, _attributes}, state), do: %{state | entry: %Entry{} }
  defp sax_event_handler({:endElement, _uri, 'item', _prefix}, state) do
    entries = [state.entry | state.feed.entries]
    feed = %{ state.feed | entries: entries}
    %{state | entry: nil,  feed: feed}
  end

  # title, either channel or item title
  defp sax_event_handler({:startElement, _uri, 'title', _prefix, _attributes}, state), do: %{state | element_acc: ""}
  defp sax_event_handler({:endElement, _uri, 'title', _prefix}, %ParserState{entry: entry} = state) when entry != nil, do: %{state | entry: %{entry | title: state.element_acc}}
  defp sax_event_handler({:endElement, _uri, 'title', _prefix}, %ParserState{meta: meta} = state), do: %{state | meta: %{meta | title: state.element_acc}}

  # link
  defp sax_event_handler({:startElement, _uri, 'link', _prefix, _attributes}, state), do: %{state | element_acc: ""}
  defp sax_event_handler({:endElement, _uri, 'link', _prefix}, %ParserState{meta: meta} = state), do: %{state | meta: %{meta | link: state.element_acc}}

  # description
  defp sax_event_handler({:startElement, _uri, 'description', _prefix, _attributes}, state), do: %{state | element_acc: ""}
  defp sax_event_handler({:endElement, _uri, 'description', _prefix}, %ParserState{entry: entry} = state) when entry != nil, do: %{state | entry: %{entry | description: state.element_acc}}
  defp sax_event_handler({:endElement, _uri, 'description', _prefix}, %ParserState{meta: meta} = state), do: %{state | meta: %{meta | description: state.element_acc}}

  # author
  defp sax_event_handler({:startElement, _uri, 'author', _prefix, _attributes}, state), do: %{state | element_acc: ""}
  defp sax_event_handler({:endElement, _uri, 'author', _prefix}, %ParserState{meta: meta} = state), do: %{state | meta: %{meta | author: state.element_acc}}

  # language
  defp sax_event_handler({:startElement, _uri, 'language', _prefix, _attributes}, state), do: %{state | element_acc: ""}
  defp sax_event_handler({:endElement, _uri, 'language', _prefix}, %ParserState{meta: meta} = state), do: %{state | meta: %{meta | language: state.element_acc}}

  # copyright
  defp sax_event_handler({:startElement, _uri, 'copyright', _prefix, _attributes}, state), do: %{state | element_acc: ""}
  defp sax_event_handler({:endElement, _uri, 'copyright', _prefix}, %ParserState{meta: meta} = state), do: %{state | meta: %{meta | copyright: state.element_acc}}





  # push all chars onto the accumulator
  defp sax_event_handler({:characters, chars}, state) do
    x = "#{state.element_acc}#{chars}"
    %{state | element_acc: x}
  end



  defp sax_event_handler({:startElement, _uri, _local_name, _prefix, _attributes}, state) do
    # IO.puts "-> startElement: #{uri} #{prefix}:#{local_name}"
    state
  end

  defp sax_event_handler({:endElement, _uri, _local_name, _prefix}, state) do
    # IO.puts "-> endElement: #{prefix}:#{local_name}"
    state
  end

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
end

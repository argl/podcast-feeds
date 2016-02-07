defmodule PodcastFeeds.Parsers.Ext.Psc do

  use Timex
  import SweetXml

  alias PodcastFeeds.Parsers.Helpers

  alias PodcastFeeds.Parsers.RSS2.ParserState

  # Podcast Simple Chapter chapter element
  defmodule Chapter do
    defstruct start: nil,
              title: nil,
              href: nil,
              image: nil
  end

  @namespace_uri "http://podlove.org/simple-chapters"

  def do_parse(%ParserState{} = state) do
    state
    |> do_parse_entries
  end

  def do_parse_entries(%ParserState{doc: doc, feed: feed} = state) do
    entries = feed.entries
    entries = doc
    |> xpath(~x"/rss/channel/item"el)
    |> Enum.zip(entries)
    |> Enum.map(fn({node, entry}) ->
      node 
      |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='chapters']"e)
      |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='chapter']"el)
      |> Enum.map(fn(psc_node) -> 
        %Chapter{
          start: psc_node |> xpath(~x"./@start"os) |> Helpers.strip_nil,
          title: psc_node |> xpath(~x"./@title"os) |> Helpers.strip_nil,
          href: psc_node |> xpath(~x"./@href"os) |> Helpers.strip_nil,
          image: psc_node |> xpath(~x"./@image"os) |> Helpers.strip_nil,
        }
      end)
      |> (fn(chapters)-> 
        put_in entry.chapters, chapters
      end).()
    end)
    put_in state.feed.entries, entries
  end

end
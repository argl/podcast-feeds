defmodule PodcastFeeds.Parsers.Ext.Content do

  # subset of the content module of the rdf framework

  use Timex
  import SweetXml

  alias PodcastFeeds.Parsers.Helpers

  alias PodcastFeeds.Parsers.ParserState

  @namespace_uri "http://purl.org/rss/1.0/modules/content/"

  def do_parse(%ParserState{} = state, {_root_path, entries_path}) do
    state
    |> do_parse_entries(entries_path)
  end

  def do_parse_entries(%ParserState{doc: doc, feed: feed} = state, entries_path) do
    entries = feed.entries
    entries = doc
    |> xpath(entries_path)
    |> Enum.zip(entries)
    |> Enum.map(fn({node, entry}) ->
      node 
      |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='encoded']/text()"os)
      |> Helpers.strip_nil
      |> (fn(content) ->
        put_in entry.content_encoded, content
      end).()
    end)
    put_in state.feed.entries, entries
  end

end
defmodule PodcastFeeds.Parsers.Atom do

  use Timex
  import SweetXml

  alias PodcastFeeds.Feed
  alias PodcastFeeds.Entry
  alias PodcastFeeds.Meta
  alias PodcastFeeds.Enclosure

  alias PodcastFeeds.Parsers.Helpers

  alias PodcastFeeds.Parsers.Ext.Itunes
  alias PodcastFeeds.Parsers.Ext.Psc
  alias PodcastFeeds.Parsers.Ext.Content
  alias PodcastFeeds.Parsers.Ext.Atom

  alias PodcastFeeds.Parsers.ParserState

  def valid?(xml) do
    case xpath(xml, ~x"/feed") do
      nil -> false
      _ -> true
    end
  end

  def parse_feed(xml) do
    %ParserState{doc: xml, feed: %Feed{} }
    |> do_parse
  end

  def do_parse(%ParserState{} = state) do
    state
    |> do_parse_meta
    |> do_parse_entries
  end

  def do_parse_meta(%ParserState{doc: doc} = state) do
    meta = doc
    |> xpath(~x"/feed")
    |> (fn(node) ->
      %Meta{
        title: node |> xpath(~x"./title/text()"s) |> Helpers.strip_nil,
        link: node |> xpath(~x"./link/@href"s) |> Helpers.strip_nil,
        author: node |> xpath(~x"./author/name/text()"os) |> Helpers.strip_nil,
        last_build_date: node |> xpath(~x"./updated/text()"os) |> Helpers.parse_date("{ISOz}")
      }
      |> Atom.do_parse_meta_node(node)
      |> Itunes.do_parse_meta_node(node)
      |> Psc.do_parse_meta_node(node)
      |> Content.do_parse_meta_node(node)

    end).()

    state = put_in state.feed.meta, meta
    state
  end

  def do_parse_entries(%ParserState{doc: doc} = state) do
    entries = doc
    |> xpath(~x"/feed/entry"el)
    |> Enum.map(fn(node) -> 
      %Entry{
        # require: title or description
        title: node |> xpath(~x"./title/text()"s) |> Helpers.strip_nil,
        description: node |> xpath(~x"./summary/text()"s) |> Helpers.strip_nil,
        link: node |> xpath(~x"./link/@href"s) |> Helpers.strip_nil,
        publication_date: node |> xpath(~x"./updated/text()"os) |> Helpers.parse_date("{ISOz}"),
        enclosure: node |> xpath(~x"./enclosure"oe) |> parse_enclosure_element
      }
      |> Atom.do_parse_entry_node(node)
      |> Itunes.do_parse_entry_node(node)
      |> Psc.do_parse_entry_node(node)
      |> Content.do_parse_entry_node(node)
    end)
    state = put_in state.feed.entries, entries
    state
  end


  defp parse_enclosure_element(node) do
    case node do
      nil -> nil
      _ ->
        %Enclosure{
          url: node |> xpath(~x"@url"s) |> Helpers.strip_nil,
          length: node |> xpath(~x"@length"s) |> Helpers.strip_nil,
          type: node |> xpath(~x"@type"s) |> Helpers.strip_nil,
        }
    end
  end


end
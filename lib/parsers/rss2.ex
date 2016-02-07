defmodule PodcastFeeds.Parsers.RSS2 do

  use Timex
  import SweetXml

  alias PodcastFeeds.Feed
  alias PodcastFeeds.Entry
  alias PodcastFeeds.Meta
  alias PodcastFeeds.Enclosure
  alias PodcastFeeds.Image
  alias PodcastFeeds.Cloud

  alias PodcastFeeds.Parsers.Helpers

  alias PodcastFeeds.Parsers.Ext.Atom
  alias PodcastFeeds.Parsers.Ext.Itunes
  alias PodcastFeeds.Parsers.Ext.Psc

  defmodule ParserState do
    defstruct doc: nil,
      feed: nil
  end

  def parse_feed(xml) do
    %ParserState{doc: xml, feed: %Feed{} }
    |> do_parse
    |> Atom.do_parse
    |> Itunes.do_parse
    |> Psc.do_parse
  end

  def do_parse(%ParserState{} = state) do
    state
    |> do_parse_meta
    |> do_parse_entries
  end

  def do_parse_meta(%ParserState{doc: doc} = state) do
    meta = doc
    |> xpath(~x"/rss/channel")
    |> (fn(node) ->
      %Meta{
        # required: title, link, description
        title: node |> xpath(~x"./title/text()"s) |> Helpers.strip_nil,
        link: node |> xpath(~x"./link/text()"s) |> Helpers.strip_nil,
        description: node |> xpath(~x"./description/text()"s) |> Helpers.strip_nil,
        # optional:
        # language, copyright, managingEditor, webMaster, pubDate, lastBuildDate, category (a list), 
        # generator, docs (ignored), cloud, ttl, image, rating (ignored), textInput (ignored), 
        # skipHours, skipDays
        # author? its not in the specs on channel level, see http://cyber.law.harvard.edu/rss/rss.html, 
        # we include it nonetheless because.
        author: node |> xpath(~x"./author/text()"os) |> Helpers.strip_nil |> Helpers.parse_email,
        language: node |> xpath(~x"./language/text()"os) |> Helpers.strip_nil,
        copyright:  node |> xpath(~x"./copyright/text()"os) |> Helpers.strip_nil,
        managing_editor: node |> xpath(~x"./managingEditor/text()"os) |> Helpers.strip_nil |> Helpers.parse_email,
        web_master: node |> xpath(~x"./webMaster/text()"os) |> Helpers.strip_nil |> Helpers.parse_email,
        publication_date: node |> xpath(~x"./pubDate/text()"os) |> Helpers.parse_date,
        last_build_date: node |> xpath(~x"./lastBuildDate/text()"os) |> Helpers.parse_date,
        categories: node |> xpath(~x"./category/text()"osl)
          |> Enum.map(fn(el) -> Helpers.strip_nil(el) end) 
          |> Enum.filter(fn(el)-> el != nil end),
        generator: node |> xpath(~x"./generator/text()"os) |> Helpers.strip_nil,
        cloud: node |> xpath(~x"./cloud"oe) |> parse_cloud_element,
        ttl: node |> xpath(~x"./ttl/text()"os) |> Helpers.parse_integer,
        image: node |> xpath(~x"./image"oe) |>parse_image_element,
        skip_hours: node |> xpath(~x"./skipHours/hour/text()"osl) 
          |> Enum.map(fn(el) -> Helpers.parse_integer(el) end) 
          |> Enum.filter(fn(el)-> el != nil end),
        skip_days: node |> xpath(~x"./skipDays/day/text()"osl)
          |> Enum.map(fn(el) -> Helpers.strip_nil(el) end) 
          |> Enum.filter(fn(el)-> el != nil end),
      }
    end).()
    # |> IO.inspect
    state = put_in state.feed.meta, meta
    state
  end

  def do_parse_entries(%ParserState{doc: doc} = state) do
    entries = doc
    |> xpath(~x"/rss/channel/item"el)
    |> Enum.map(fn(node) -> 
      %Entry{
        # require: title or description
        title: node |> xpath(~x"./title/text()"s) |> Helpers.strip_nil,
        description: node |> xpath(~x"./description/text()"s) |> Helpers.strip_nil,
        # optional: link, author, category, comments (URL of a page for comments relating to the item), 
        # enclosure, guid, pubDate, source (The RSS channel that the item came from)
        link: node |> xpath(~x"./link/text()"s) |> Helpers.strip_nil,
        author: node |> xpath(~x"./author/text()"os) |> Helpers.strip_nil |> Helpers.parse_email,
        categories: node |> xpath(~x"./category/text()"osl)
          |> Enum.map(fn(el) -> Helpers.strip_nil(el) end) 
          |> Enum.filter(fn(el)-> el != nil end),
        comments: node |> xpath(~x"./comments/text()"os) |> Helpers.strip_nil,
        enclosure: node |> xpath(~x"./enclosure"oe) |> parse_enclosure_element,
        guid: node |> xpath(~x"./guid/text()"os) |> Helpers.strip_nil,
        publication_date: node |> xpath(~x"./pubDate/text()"os) |> Helpers.parse_date,
        source: node |> xpath(~x"./source/text()"os) |> Helpers.strip_nil,
      }
    end)
    # |> IO.inspect
    state = put_in state.feed.entries, entries
    state
  end

  defp parse_enclosure_element(node) do
    %Enclosure{
      url: node |> xpath(~x"@url"s) |> Helpers.strip_nil,
      length: node |> xpath(~x"@length"s) |> Helpers.strip_nil,
      type: node |> xpath(~x"@type"s) |> Helpers.strip_nil,
    }
  end


  defp parse_cloud_element(node) do
    %Cloud{
      domain: node |> xpath(~x"@domain"s) |> Helpers.strip_nil,
      port: node |> xpath(~x"@port"s) |> Helpers.parse_integer,
      path: node |> xpath(~x"@path"s) |> Helpers.strip_nil,
      register_procedure: node |> xpath(~x"@registerProcedure"s),
      protocol: node |> xpath(~x"@protocol"s)
    }
  end

  defp parse_image_element(node) do
    %Image{
      title: node |> xpath(~x"./title/text()"os) |> Helpers.strip_nil,
      url: node |> xpath(~x"./url/text()"os) |> Helpers.strip_nil,
      link: node |> xpath(~x"./link/text()"os) |> Helpers.strip_nil,
      width: node |> xpath(~x"./width/text()"os) |> Helpers.parse_integer,
      height: node |> xpath(~x"./height/text()"os) |> Helpers.parse_integer,
      description: node |> xpath(~x"./description/text()"os) |> Helpers.strip_nil
    }
  end

end

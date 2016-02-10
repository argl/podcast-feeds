defmodule PodcastFeeds.Parsers.Ext.Psc do

  use Timex
  import SweetXml

  alias PodcastFeeds.Parsers.Helpers

  # Podcast Simple Chapter chapter element
  defmodule Chapter do
    defstruct start: nil,
              title: nil,
              href: nil,
              image: nil
  end

  @namespace_uri "http://podlove.org/simple-chapters"


  def do_parse_meta_node(meta, _node) do
    meta
  end

  def do_parse_entry_node(entry, node) do
    chapters = node
    |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='chapters']/*[namespace-uri()='#{@namespace_uri}' and local-name()='chapter']"el)
    |> Enum.map(fn(psc_node) -> 
      %Chapter{
        start: psc_node |> xpath(~x"./@start"os) |> Helpers.strip_nil,
        title: psc_node |> xpath(~x"./@title"os) |> Helpers.strip_nil,
        href: psc_node |> xpath(~x"./@href"os) |> Helpers.strip_nil,
        image: psc_node |> xpath(~x"./@image"os) |> Helpers.strip_nil,
      }
    end)
    put_in entry.chapters, chapters
  end

end
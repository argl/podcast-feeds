defmodule PodcastFeeds.Parsers.Ext.Content do

  # subset of the content module of the rdf framework

  use Timex
  import SweetXml

  alias PodcastFeeds.Parsers.Helpers

  @namespace_uri "http://purl.org/rss/1.0/modules/content/"


  def do_parse_meta_node(meta, _node) do
    meta
  end

  def do_parse_entry_node(entry, node) do
    content_encoded = node 
    |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='encoded']/text()"os)
    |> Helpers.strip_nil
    put_in entry.content_encoded, content_encoded
  end

end
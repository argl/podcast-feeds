defmodule PodcastFeeds.Parsers.Ext.Atom do

  use Timex
  import SweetXml

  alias PodcastFeeds.Parsers.Helpers


  # atom:link element, used in various contexts
  defmodule Link do
    defstruct rel: nil,
              type: nil,
              href: nil,
              title: nil
  end

  # atom:contributor, used in entries
  defmodule Contributor do
    defstruct name: nil,
      email: nil,
      uri: nil
  end

  @namespace_uri "http://www.w3.org/2005/Atom"

  # # <atom:link rel="self" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (MPEG-4 AAC Audio)" href="http://feeds.metaebene.me/cre/m4a"/>
  # # <atom:link rel="alternate" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (MP3 Audio)" href="http://cre.fm/feed/mp3"/>
  # # <atom:link rel="alternate" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (Ogg Vorbis Audio)" href="http://cre.fm/feed/oga"/>
  # # <atom:link rel="alternate" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (Ogg Opus Audio)" href="http://cre.fm/feed/opus"/>
  # # <atom:link rel="next" href="http://cre.fm/feed/m4a?paged=2"/>
  # # <atom:link rel="first" href="http://cre.fm/feed/m4a"/>
  # # <atom:link rel="last" href="http://cre.fm/feed/m4a?paged=4"/>

  def do_parse_meta_node(meta, node) do
    atom_links = node
    |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='link']"el)
    |> Enum.map(fn(node) -> 
      %Link{
        rel: node |> xpath(~x"@rel"s) |> Helpers.strip_nil,
        type: node |> xpath(~x"@type"s) |> Helpers.strip_nil,
        href: node |> xpath(~x"@href"s) |> Helpers.strip_nil,
        title: node |> xpath(~x"@title"s) |> Helpers.strip_nil,
      }      
    end)
    put_in meta.atom_links, atom_links
  end

  def do_parse_entry_node(entry, node) do
    atom_links = node
    |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='link']"el)
    |> Enum.map(fn(atom_node) -> 
      %Link{
        rel: atom_node |> xpath(~x"@rel"s) |> Helpers.strip_nil,
        type: atom_node |> xpath(~x"@type"s) |> Helpers.strip_nil,
        href: atom_node |> xpath(~x"@href"s) |> Helpers.strip_nil,
        title: atom_node |> xpath(~x"@title"s) |> Helpers.strip_nil,
      }      
    end)
    entry = put_in entry.atom_links, atom_links

    contributors = node 
    |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='contributor']"el)
    |> Enum.map(fn(atom_node) -> 
      %Contributor{
        name: atom_node |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='name']/text()"s) |> Helpers.strip_nil,
        email: atom_node |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='email']/text()"s) |> Helpers.strip_nil |> Helpers.parse_email,
        uri: atom_node |> xpath(~x"*[namespace-uri()='#{@namespace_uri}' and local-name()='uri']/text()"s) |> Helpers.strip_nil,
      }
    end)
    put_in entry.contributors, contributors
  end

end
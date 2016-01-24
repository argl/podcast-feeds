defmodule PodcastFeeds.Parsers.Ext.Atom do

  use Timex
  import SweetXml

  alias PodcastFeeds.Feed
  alias PodcastFeeds.Entry
  alias PodcastFeeds.Meta
  alias PodcastFeeds.Itunes
  alias PodcastFeeds.Image
  alias PodcastFeeds.SkipDays
  alias PodcastFeeds.SkipHours
  alias PodcastFeeds.Cloud

  alias PodcastFeeds.Parsers.Helpers

  alias PodcastFeeds.Parsers.RSS2.ParserState
  # alias PodcastFeeds.Contributor

  # atom:link element, used in various contexts
  defmodule Link do
    defstruct rel: nil,
              type: nil,
              href: nil,
              title: nil
  end


  @namespace_uri "http://www.w3.org/2005/Atom"

  def do_parse(%ParserState{doc: doc, feed: feed} = state) do
    state
    |> do_parse_meta
    |> do_parse_entries
  end

  def do_parse_meta(%ParserState{doc: doc, feed: feed} = state) do
    atom_links = doc
    |> xpath(~x"/rss/channel/*[namespace-uri()='#{@namespace_uri}' and local-name()='link']"el)
    |> Enum.map(fn(node) -> 
      %Link{
        rel: node |> xpath(~x"@rel"s) |> Helpers.strip_nil,
        type: node |> xpath(~x"@type"s) |> Helpers.strip_nil,
        href: node |> xpath(~x"@href"s) |> Helpers.strip_nil,
        title: node |> xpath(~x"@title"s) |> Helpers.strip_nil,
      }      
    end)
    # |> IO.inspect
    state = put_in state.feed.meta.atom_links, atom_links
    state
  end

  def do_parse_entries(%ParserState{doc: doc, feed: feed} = state) do
    entries = doc
    |> xpath(~x"/rss/channel/item"el)
    |> Enum.map(fn(node) -> 
      node 
      |> xpath(~x"/rss/channel/*[namespace-uri()='#{@namespace_uri}' and local-name()='link']"el)
      |> Enum.map(fn(node) -> 
        %Link{
          rel: node |> xpath(~x"@rel"s) |> Helpers.strip_nil,
          type: node |> xpath(~x"@type"s) |> Helpers.strip_nil,
          href: node |> xpath(~x"@href"s) |> Helpers.strip_nil,
          title: node |> xpath(~x"@title"s) |> Helpers.strip_nil,
        }      
      end)
    end)
    # |> IO.inspect
    #state = put_in state.feed.entries, entries
    state
  end
  
  # @prefix 'atom'

  # # <atom:link rel="self" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (MPEG-4 AAC Audio)" href="http://feeds.metaebene.me/cre/m4a"/>
  # # <atom:link rel="alternate" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (MP3 Audio)" href="http://cre.fm/feed/mp3"/>
  # # <atom:link rel="alternate" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (Ogg Vorbis Audio)" href="http://cre.fm/feed/oga"/>
  # # <atom:link rel="alternate" type="application/rss+xml" title="CRE: Technik, Kultur, Gesellschaft (Ogg Opus Audio)" href="http://cre.fm/feed/opus"/>
  # # <atom:link rel="next" href="http://cre.fm/feed/m4a?paged=2"/>
  # # <atom:link rel="first" href="http://cre.fm/feed/m4a"/>
  # # <atom:link rel="last" href="http://cre.fm/feed/m4a?paged=4"/>


  # def sax_event_handler({:startElement, _uri, 'link', @prefix, attr}, state) do
  #   %ParserState{element_stack: [elem | element_stack]} = state
  #   case elem.__struct__ do
  #     PodcastFeeds.Meta ->
  #       attr_map = Helpers.extract_attributes(attr)
  #       elem = %{elem | atom_links: [attr_map | elem.atom_links]}
  #       %{state | element_stack: [elem | element_stack]}
  #     PodcastFeeds.Entry ->
  #       attr_map = Helpers.extract_attributes(attr)
  #       elem = %{elem | atom_links: [attr_map | elem.atom_links]}
  #       %{state | element_stack: [elem | element_stack]}
  #     _ -> state
  #   end
  # end

  # # <atom:contributor>
  # #   <atom:name>Harry Schwitzer</atom:name>
  # #   <atom:email>h.schwitzer@celawi.eu </atom:email>
  # #   <atom:uri>http://www.celawi.eu/harry </atom:uri>
  # # </atom:contributor> 

  # def sax_event_handler({:startElement, _uri, 'contributor', @prefix, _attr}, state) do
  #   element_stack = [%Contributor{} | state.element_stack]
  #   %{state | element_stack: element_stack}
  # end
  # def sax_event_handler({:endElement, _uri, 'contributor', @prefix}, state) do
  #   [contributor | element_stack] = state.element_stack
  #   [elem | element_stack] = element_stack
  #   elem = %{elem | contributors: [contributor | elem.contributors]}
  #   element_stack = [elem | element_stack]
  #   %{state | element_stack: element_stack}
  # end
  # def sax_event_handler({:startElement, _uri, 'name', @prefix, _attributes}, state) do
  #   %{state | element_acc: ""}
  # end
  # def sax_event_handler({:endElement, _uri, 'name', @prefix}, state) do
  #   state
  #   |> Helpers.map_character_content(:name, PodcastFeeds.Contributor)
  # end
  # def sax_event_handler({:startElement, _uri, 'email', @prefix, _attributes}, state) do
  #   %{state | element_acc: ""}
  # end
  # def sax_event_handler({:endElement, _uri, 'email', @prefix}, state) do
  #   state
  #   |> Helpers.map_character_content(:email, PodcastFeeds.Contributor)
  # end
  # def sax_event_handler({:startElement, _uri, 'uri', @prefix, _attributes}, state) do
  #   %{state | element_acc: ""}
  # end
  # def sax_event_handler({:endElement, _uri, 'uri', @prefix}, state) do
  #   state
  #   |> Helpers.map_character_content(:uri, PodcastFeeds.Contributor)
  # end




  # def sax_event_handler({:startElement, _uri, _name, @prefix, _attributes}, state) do
  #   state
  # end
  # def sax_event_handler({:endElement, _uri, _name, @prefix}, state) do
  #   state
  # end

end
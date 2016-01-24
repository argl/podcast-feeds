defmodule PodcastFeeds.Parsers.Ext.Atom do

  # alias PodcastFeeds.Parsers.Helpers
  # alias PodcastFeeds.Parsers.RSS2.ParserState
  # alias PodcastFeeds.Contributor

  
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
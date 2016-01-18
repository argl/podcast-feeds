defmodule PodcastFeeds.Parsers.Ext.Itunes do

  alias PodcastFeeds.Parsers.Helpers
  alias PodcastFeeds.Parsers.Helpers.ParserState
  alias PodcastFeeds.Contributor
  alias PodcastFeeds.Entry
  
  @prefix 'itunes'

  # xml tag                 channel   item  Location of content in iTunes / Notes
  # <itunes:author>               Y   Y     Visible under podcast title and in iTunes Store Browse
  # <itunes:block>                Y   Y     Prevent an episode or podcast from appearing
  # <itunes:category>             Y         Visible under podcast details and in iTunes Store Browse
  # <itunes:image>                Y   Y     Same location as album art
  # <itunes:duration>                 Y     Time column
  # <itunes:explicit>             Y   Y     Parental advisory graphic under podcast details or episode badge in Name column
  # <itunes:isClosedCaptioned>        Y     Closed Caption graphic in Name column
  # <itunes:order>                    Y     Override the order of episodes on the store
  # <itunes:complete>             Y         Indicates podcast complete; no more episodes
  # <itunes:new-feed-url>         Y         Not visible, reports new feed URL to iTunes
  # <itunes:owner>                Y         Not visible, used for contact only
  # <itunes:subtitle>             Y   Y     Description column
  # <itunes:summary>              Y   Y     When the "circled i” icon in the Description column is clicked


  # <itunes:author>
  # The content of this tag is shown in the Artist column in iTunes. If the <itunes:author> tag is 
  # not present, iTunes uses the contents of the <author> tag. If <itunes:author> is not present 
  # at the RSS podcast feed level, iTunes will use the contents of <managingEditor>.

  def sax_event_handler({:startElement, _uri, 'author', @prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  def sax_event_handler({:endElement, _uri, 'author', @prefix}, state) do
    state
    |> handle_character_content_for_itunes([PodcastFeeds.Meta, PodcastFeeds.Entry], :author)
  end


  # <itunes:block>
  # If the <itunes:block> tag is present and populated with the “yes” value inside a <channel> (podcast) element, 
  # it will prevent the entire podcast from appearing in the iTunes Store podcast directory.
  # If the <itunes:block> tag is present and populated with the “yes” value inside an <item> (episode) element, 
  # it will prevent that episode from appearing in the iTunes Store podcast directory. For example, you may want
  # to block a specific episode if you know that its content would otherwise cause the entire podcast to be removed 
  # from the iTunes Store.
  # If the <itunes:block> tag is populated with any other value, it will have no effect.
  def sax_event_handler({:startElement, _uri, 'block', @prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  def sax_event_handler({:endElement, _uri, 'block', @prefix}, state) do
    state
    |> (fn(state) ->
      case state.element_acc do
        "yes" -> state
        _ -> %{state | element_acc: nil}
      end
    end).()
    |> handle_character_content_for_itunes([PodcastFeeds.Meta, PodcastFeeds.Entry], :block)
  end

  # <itunes:category>
  # Users can browse podcast subject categories on iTunes using one of two methods:
  # - click Browse under Features at the bottom of the iTunes Store window to open a text-
  # based table
  # - choose a category from the Podcasts pop-up menu in the navigation bar, which leads 
  # to pages that include the podcast art.
  # Within the older, text-based browsing system, podcast feeds may list up to three 
  # category and subcategory pairs. (For example, “Music” counts as one of the three items, 
  #   as does “Business > Careers.”)
  # Use the <itunes:category> tag to specify the browsing category. You must also define 
  # a subcategory if one is available within your category.
  # Within the newer browsing system based on Category links, including the Top Podcasts 
  # and Top Episodes lists, only the first category listed in the feed will be recognized. 
  # A complete list of categories and subcategories included at the end of this document.
  # Be sure to properly escape ampersands as shown below.

  # Examples:
  # Single category:
  # <itunes:category text="Music" />

  # Category with ampersand:
  # <itunes:category text="TV &amp; Film" />
  # Category with subcategory:
  # <itunes:category text="Society &amp; Culture">
  #   <itunes:category text="History" />
  # </itunes:category>

  # Entry with multiple categories:
  # <itunes:category text="Society &amp; Culture">
  #   <itunes:category text="History" />
  # </itunes:category>
  # <itunes:category text="Technology">
  #   <itunes:category text="Gadgets" />
  # </itunes:category>

  # %{
  #   "Arts" => %{}
  #   "Society & Culture" => %{
  #     "History" => %{},
  #     "Another Subcategory" => %{}
  #   },
  #   "Technology" => %{
  #     "Gadgets" => %{}
  #   }
  # }

  def sax_event_handler({:startElement, _uri, 'category', @prefix, attr}, state) do
    # IO.puts "===== start"
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state

    category = Helpers.extract_attributes(attr).text
    _accessor = fn() -> Map.fetch(element_acc, category) end

    %{state | element_stack: [elem | element_stack], element_acc: element_acc}
  end
  def sax_event_handler({:endElement, _uri, 'category', @prefix}, state) do
    # IO.puts "===== end"
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state

    %{state | element_stack: [elem | element_stack], element_acc: element_acc}
  end





  # fall through
  def sax_event_handler({:startElement, _uri, _name, @prefix, _attributes}, state) do
    state
  end
  def sax_event_handler({:endElement, _uri, _name, @prefix}, state) do
    state
  end



  # helper
  defp handle_character_content_for_itunes(state, allowed_structs, key) do
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state    
    case Enum.find(allowed_structs, &(&1 == elem.__struct__)) do
      nil -> state
      _ok ->
        itunes = %{elem.itunes | key => element_acc}
        elem = %{elem | itunes: itunes}
        %{state | element_stack: [elem | element_stack]}
    end
  end

end
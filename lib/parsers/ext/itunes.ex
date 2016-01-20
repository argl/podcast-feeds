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

  def sax_event_handler({:startElement, _uri, 'category', @prefix, attr}, state) do
    [elem | element_stack] = state.element_stack
    catstack = state.catstack
    subcatstack = state.subcatstack
    level = state.level
    category = Helpers.extract_attributes(attr).text

    catstack = case level do
      0 -> [category | catstack]
      1 -> catstack
    end

    subcatstack = case level do
      0 -> subcatstack
      1 -> [category | subcatstack]
    end

    level = level + 1

    state = put_in state.level, level
    state = put_in state.catstack, catstack
    state = put_in state.subcatstack, subcatstack
    %{state | element_stack: [elem | element_stack]}
  end
  def sax_event_handler({:endElement, _uri, 'category', @prefix}, state) do
    [elem | element_stack] = state.element_stack
    catstack = state.catstack
    subcatstack = state.subcatstack
    level = state.level
    level = level - 1

    catstack = case level do
      0 -> case subcatstack do
        [] -> catstack
        _ -> [Enum.reverse(subcatstack) | catstack]
      end
      1 -> catstack
    end

    subcatstack = case level do
      0 -> []
      1 -> subcatstack
    end

    state = put_in state.level, level
    state = put_in state.catstack, catstack
    state = put_in state.subcatstack, subcatstack
    elem = put_in elem.itunes.categories, Enum.reverse(catstack)
    %{state | element_stack: [elem | element_stack]}
  end


  # <itunes:image>

  # The <itunes:image> tag points to the artwork for your podcast, via the URL specified in 
  # the <a href> attribute.
  # Cover art must be in the JPEG or PNG file formats and in the RGB color space with a minimum 
  # size of 1400 x 1400 pixels and a maximum size of 3000 x 3000 pixels. Note that these 
  # requirements are different from the standard RSS image tag specification.
  # Potential subscribers will see your cover art in varying sizes depending on the device 
  # they’re using. Make sure your design is effective at both its original size and at 
  # thumbnail size.
  # If the <itunes:image> tag is not present, iTunes will use the content of the RSS image tag, 
  # but your podcast will not be considered for a potential feature placement in the Podcasts 
  # app and the iTunes Store.
  # We recommend including a title, brand, or source name as part of your cover art. For examples 
  # of cover art, see the Top Podcasts section in the Podcasts app or the iTunes Store.
  # If you update the cover art for your podcast, be sure to avoid technical issues by doing 
  # the following:
  # - change the cover art file name and URL at the same time
  # - verify the web server hosting your cover art allows HTTP head requests
  # The <itunes:image> tag is also supported at the <item> (episode) level.
  # For best results, we also recommend embedding the same cover art within the metadata for that 
  # episode’s media file prior to uploading to your host server. You may need to edit your media 
  # file via Garageband or other content-creation tool to do so.

  def sax_event_handler({:startElement, _uri, 'image', @prefix, attr}, state) do
    [elem | element_stack] = state.element_stack
    image_href = Helpers.extract_attributes(attr).href
    elem = put_in elem.itunes.image_href, image_href
    %{state | element_stack: [elem | element_stack]}
  end
  def sax_event_handler({:endElement, _uri, 'image', @prefix}, state) do
    state
  end


  # <itunes:duration>
  # The content of the <itunes:duration> tag is shown in the Time column in the List View on iTunes.
  # The value provided for this tag can be formatted as HH:MM:SS, H:MM:SS, MM:SS, or M:SS, where 
  # H = hours, M = minutes, S = seconds. If a single number is provided as a value (no colons are used), 
  # the value is assumed to be in seconds. If one colon is present, the number to the left is assumed to 
  # be minutes, and the number to the right is assumed to be seconds. If more than two colons are present, 
  # the numbers farthest to the right are ignored.
  def sax_event_handler({:startElement, _uri, 'duration', @prefix, attr}, state) do
    %{state | element_acc: ""}
  end
  def sax_event_handler({:endElement, _uri, 'duration', @prefix}, state) do
    [elem | element_stack] = state.element_stack
    duration = state.element_acc
    case elem.__struct__ do
      PodcastFeeds.Entry -> 
        elem = put_in elem.itunes.duration, duration
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
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
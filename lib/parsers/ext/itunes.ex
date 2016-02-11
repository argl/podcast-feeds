defmodule PodcastFeeds.Parsers.Ext.Itunes do

  use Timex
  import SweetXml

  alias PodcastFeeds.Parsers.Helpers

  @namespace_uri "http://www.itunes.com/dtds/podcast-1.0.dtd"

  # Itunes struct, used in Meta and Entry structs
  defmodule Itunes do
    defstruct author: nil,
              block: false,
              categories: [],
              image_href: nil,
              duration: nil,
              explicit: false,
              is_closed_captioned: false,
              order: nil,
              complete: false,
              new_feed_url: nil,
              owner: nil,
              subtitle: nil,
              summary: nil
  end

  # itunes owner
  defmodule Owner do
    defstruct name: nil,
      email: nil
  end

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


  def do_parse_meta_node(meta, node) do
    itunes = node
    |> (fn(node) ->
      %Itunes{
        # <itunes:author>
        # The content of this tag is shown in the Artist column in iTunes. If the <itunes:author> tag is 
        # not present, iTunes uses the contents of the <author> tag. If <itunes:author> is not present 
        # at the RSS podcast feed level, iTunes will use the contents of <managingEditor>.
        author: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='author']/text()"os) |> Helpers.strip_nil,

        # <itunes:block>
        # If the <itunes:block> tag is present and populated with the “yes” value inside a <channel> (podcast) element, 
        # it will prevent the entire podcast from appearing in the iTunes Store podcast directory.
        # If the <itunes:block> tag is present and populated with the “yes” value inside an <item> (episode) element, 
        # it will prevent that episode from appearing in the iTunes Store podcast directory. For example, you may want
        # to block a specific episode if you know that its content would otherwise cause the entire podcast to be removed 
        # from the iTunes Store.
        # If the <itunes:block> tag is populated with any other value, it will have no effect.
        block: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='block']/text()"os) |> Helpers.parse_yes_no_boolean,


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
        categories: node |> parse_categories,

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
        image_href: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='image']/@href"os) |> Helpers.strip_nil,

        # <itunes:explicit>
        # The <itunes:explicit> tag indicates whether your podcast contains explicit material. The two usable values 
        # for this tag are “yes” and “clean”.
        # If you populate this tag with the “yes” value, indicating the presence of explicit content, an “explicit” 
        # parental advisory graphic will appear.
        # If you populate this tag with the “clean” value, indicating that none of your podcast episodes contain explicit 
        # language or adult content, a “clean” parental advisory graphic will appear.
        # If you populate this tag with any other value besides “yes” or “clean,” neither of the parental advisory graphics 
        # will appear and that space will remain blank.
        # Note that podcasts that contain explicit material are not available in some iTunes Store territories.
        explicit: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='explicit']/text()"os) |> parse_explicit_value,

        # <itunes:complete>
        # The <itunes:complete> tag, populated with a “yes” value, indicates that a podcast has been completed 
        # and no further episodes will be posted in the future.
        # If you populate this tag with any other value, it will have no effect.
        # This tag is only supported at a <channel> (podcast) level.
        complete: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='complete']/text()"os) |> Helpers.parse_yes_no_boolean,

        # <itunes:new-feed-url>
        # The <itunes:new-feed-url> tag allows you to change the URL where the RSS podcast feed is located, for example:
        # <itunes:new-feed-url>http://newlocation.com/example.rss</itunes:new-feed-url>
        # After adding the tag to your old feed, you should maintain the old feed for 48 hours before retiring it.
        # For more information, please see the “Changing Your Feed URL” section earlier in this document.
        # This tag is only supported at a <channel> (podcast) level.
        new_feed_url: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='new-feed-url']/text()"os) |> Helpers.strip_nil,

        # <itunes:owner>
        # The <itunes:owner> tag contains contact information for the owner of the podcast intended to be used 
        # for administrative communication about the podcast. This information is not displayed on the iTunes Store.
        # The email address of the owner should be included in a nested <itunes:email> element. Include the name 
        # of the owner in a nested <itunes:name> element.
        owner: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='owner']") |> parse_owner,

        # <itunes:subtitle>
        # The contents of the <itunes:subtitle> tag are displayed in the Description column in iTunes. For best 
        # results, choose a subtitle that is only a few words long.
        subtitle: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='subtitle']/text()"os) |> Helpers.strip_nil,

        # <itunes:summary>
        # The contents of the <itunes:summary> tag are shown on the iTunes Store page for your podcast. The 
        # information also appears in a separate window if the information (“i”) icon in the Description 
        # column is clicked. This field can be up to 4000 characters.
        # If a <itunes:summary> tag is not included, the contents of the <description> tag are used.
        summary: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='summary']/text()"os) |> Helpers.strip_nil,
      }
    end).()
    put_in meta.itunes, itunes
  end

  def do_parse_entry_node(entry, node) do
    itunes = node
    |> (fn(node) ->
      %Itunes{
        author: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='author']/text()"os) |> Helpers.strip_nil,
        block: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='block']/text()"os) |> Helpers.parse_yes_no_boolean,
        image_href: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='image']/@href"os) |> Helpers.strip_nil,
        
        # <itunes:duration>
        # The content of the <itunes:duration> tag is shown in the Time column in the List View on iTunes.
        # The value provided for this tag can be formatted as HH:MM:SS, H:MM:SS, MM:SS, or M:SS, where 
        # H = hours, M = minutes, S = seconds. If a single number is provided as a value (no colons are used), 
        # the value is assumed to be in seconds. If one colon is present, the number to the left is assumed to 
        # be minutes, and the number to the right is assumed to be seconds. If more than two colons are present, 
        # the numbers farthest to the right are ignored.
        duration: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='duration']/text()"os) |> Helpers.strip_nil,
        
        explicit: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='explicit']/text()"os) |> parse_explicit_value,
        
        # <itunes:isClosedCaptioned>
        # The <itunes:isClosedCaptioned> tag should be used with a “yes” value for a video podcast episode with 
        # embedded closed captioning.
        # A closed-caption icon will appear next to the corresponding episode.
        # If the closed-caption tag is present and has any other value, no closed-caption indicator will appear.
        # This tag is only supported at the <item> (episode) level.
        is_closed_captioned: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='isClosedCaptioned']/text()"os) |> Helpers.parse_yes_no_boolean,
        
        # <itunes:order>
        # The <itunes:order> tag can be used to override the default ordering of episodes on the iTunes Store by 
        # populating it with the number value in which you would like the episode to appear. For example, if you 
        # would like an <item> to appear as the first episode of the podcast, you would populate the <itunes:order> 
        # tag with “1.” If conflicting order values are present in multiple episodes, the store will order by 
        order: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='order']/text()"os) |> Helpers.parse_integer,
        
        subtitle: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='subtitle']/text()"os) |> Helpers.strip_nil,
        summary: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='summary']/text()"os) |> Helpers.strip_nil,
      }
    end).()
    put_in entry.itunes, itunes
  end

  defp parse_owner(nil), do: nil
  defp parse_owner(node) do
    %Owner{
      name: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='name']/text()"os) |> Helpers.strip_nil,
      email: node |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='email']/text()"os) |> Helpers.strip_nil |> Helpers.parse_email
    }
  end

  defp parse_explicit_value(nil), do: nil
  defp parse_explicit_value(val) when is_binary(val) do
    case String.downcase(val) do
      "yes" -> true
      "clean" -> false
      _ -> nil
    end
  end
  defp parse_explicit_value(_), do: nil

  defp parse_categories(nil), do: nil
  defp parse_categories(node) do
    node 
    |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='category']"el)
    |> Enum.map(fn(category_element) -> 
      category_name = category_element |> xpath(~x"./@text"os) |> Helpers.strip_nil
      case category_name do
        nil -> nil
        _ -> 
          subcategory_name = category_element |> xpath(~x"./*[namespace-uri()='#{@namespace_uri}' and local-name()='category']/@text"os) |> Helpers.strip_nil
          case categories[category_name] do
            [] -> [category_name]
            subcategories when is_list(subcategories) ->
              case Enum.find(subcategories, fn(x) -> x == subcategory_name end) do
                nil -> nil
                _ -> [category_name, subcategory_name]
              end
            _ -> nil
          end
      end
    end)
    |> Enum.filter(fn(x) ->
      is_list(x)
    end)
    # |> IO.inspect
  end

  defp categories do
    %{
      "Arts" => [
        "Design",
        "Fashion & Beauty",
        "Food",
        "Literature",
        "Performing Arts",
        "Visual Arts"
      ],
      "Business" => [
        "Business News",
        "Careers",
        "Investing",
        "Management & Marketing",
        "Shopping"
      ],
      "Comedy" => [],
      "Education" => [
        "Educational Technology",
        "Higher Education",
        "K-12",
        "Language Courses",
        "Training"
      ],
      "Games & Hobbies" => [
        "Automotive",
        "Aviation",
        "Hobbies",
        "Other Games",
        "Video Games"
      ],
      "Government & Organizations" => [
        "Local",
        "National",
        "Non-Profit",
        "Regional"
      ],
      "Health" => [
        "Alternative Health",
        "Fitness & Nutrition",
        "Self-Help",
        "Sexuality"
      ],
      "Kids & Family" => [],
      "Music" => [],
      "News & Politics" => [],
      "Religion & Spirituality" => [
        "Buddhism",
        "Christianity",
        "Hinduism",
        "Islam",
        "Judaism",
        "Other",
        "Spirituality"
      ],
      "Science & Medicine" => [
        "Medicine",
        "Natural Sciences",
        "Social Sciences"
      ],
      "Society & Culture" => [
        "History",
        "Personal Journals",
        "Philosophy",
        "Places & Travel"
      ],
      "Sports & Recreation" => [
        "Amateur",
        "College & High School",
        "Outdoor",
        "Professional"
      ],
      "Technology" => [
        "Gadgets",
        "Tech News",
        "Podcasting",
        "Software How-To"
      ],
      "TV & Film" => []
    }
  end

end
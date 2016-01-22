defmodule PodcastFeeds do

  # RSS2 image element
  defmodule Image do
    defstruct title: nil,
              url: nil,
              link: nil,
              width: nil,
              height: nil,
              description: nil
  end

  # RSS2 enclosure element
  defmodule Enclosure do
    defstruct url: nil,
              length: nil,
              type: nil
  end

  # Feed Meta / Channel data
  defmodule Meta do
    defstruct title: nil,
              link: nil,
              description: nil,
              author: nil,
              language: nil,
              copyright: nil,
              publication_date: nil,
              last_build_date: nil,
              generator: nil,
              categories: [],
              cloud: nil,
              ttl: nil,
              managing_editor: nil,
              web_master: nil,
              skip_hours: [],
              skip_days: [],
              image: nil,
              itunes: nil,
              atom_links: [],
              contributors: []
  end

  # Feed Entry / Episode / Item data
  defmodule Entry do
    defstruct title: nil,
              link: nil,
              description: nil,
              author: nil,
              categories: [],
              comments: nil,
              enclosure: nil,
              guid: nil,
              publication_date: nil,
              source: nil,
              itunes: nil,
              psc: [],
              atom_links: [],
              contributors: []
  end

  # A Feed
  defmodule Feed do
    defstruct meta: nil, 
              entries: [],
              namespaces: []
  end

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

  # Podcasr Simple Chapter chapters element
  defmodule Psc do
    defstruct start: nil,
              title: nil,
              href: nil,
              image: nil
  end

  # atom:link element, used in various contexts
  defmodule AtomLink do
    defstruct rel: nil,
              type: nil,
              href: nil,
              title: nil
  end

  # RSS2 Skip days, probably totally useless
  defmodule SkipDays do
    defstruct days: []
  end

  defmodule SkipHours do
    defstruct hours: []
  end

  defmodule Contributor do
    defstruct name: nil,
      email: nil,
      uri: nil
  end

  # itunes owner
  defmodule Owner do
    defstruct name: nil,
      email: nil
  end


  @chunk_size 4096

  def parse_file(filename) do
    File.stream!(filename, [], @chunk_size)
    |> parse_stream
  end

  def parse_stream(stream) do
    stream
    |> PodcastFeeds.Parsers.RSS2.parse
    |> (fn({:ok, state, rest})-> 
      {:ok, state.feed, state.namespaces, rest} 
    end).()
  end

  defp detect_parser(other), do: other

end

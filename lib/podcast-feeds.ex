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
              chapters: [],
              atom_links: [],
              contributors: []
  end

  # A Feed
  defmodule Feed do
    defstruct meta: nil, 
              entries: [],
              namespaces: []
  end



  # rss cloud element
  defmodule Cloud do
    defstruct domain: nil,
      port: nil,
      path: nil,
      register_procedure: nil,
      protocol: nil
  end





  @chunk_size 4096

  def parse

  def parse_file(filename) do
    File.stream!(filename, [], @chunk_size)
    |> parse_stream
  end

  def parse_stream(stream) do
    stream
    |> PodcastFeeds.Parsers.RSS2.parse_feed
    |> (fn(state)-> 
      {:ok, state.feed} 
    end).()
  end

  # defp detect_parser(other), do: other

end

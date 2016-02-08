defmodule PodcastFeeds.Parsers.ParserState do
  defstruct doc: nil, # the xml soc as string
    feed: nil,        # the feed
    annotations: []   # feed shaming info goes here
end

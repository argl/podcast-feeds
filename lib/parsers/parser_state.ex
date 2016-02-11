defmodule PodcastFeeds.Parsers.ParserState do
  defstruct doc: nil, # the xml soc as string
    feed: nil,        # the feed
    error: nil,
    annotations: []   # feed shaming info goes here
end

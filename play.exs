{:ok, state, _rest} = PodcastFeeds.parse_file("./test/fixtures/rss2/sample1.xml")
# IO.inspect Enum.map(state.feed.entries, &(&1.title))
IO.inspect state.feed
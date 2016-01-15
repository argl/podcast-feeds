{:ok, state, _rest} = PodcastFeeds.parse_file("./test/fixtures/rss2/cre.xml")
IO.inspect Enum.map(state.feed.entries, &(&1.title))
IO.inspect state.feed.meta
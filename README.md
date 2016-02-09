Podcast-Feeds
======

[![Build Status](https://travis-ci.org/argl/podcast-feeds.svg?branch=master)](https://travis-ci.org/argl/podcast-feeds)

Elixir RSS/Atom parser library for Podcast feeds. Built on the [erlsom](https://github.com/willemdj/erlsom) xml parser in SAX mode.
It uses [timex](https://github.com/bitwalker/timex) for parsing dates.

Podcast-Feeds eats Feeds (XML Strings) and parses them into an Elixir Struct.

```elixir
defmodule Feed do
  defstruct meta: nil, 
            entries: []
end
```
`meta`, `entries` and other structs are described in `lib/poscast-feeds.ex`


## Setup

For a quick check in iex:

```
mix deps.get
iex -S mix
iex(5)> PodcastFeeds.parse(File.read!("test/fixtures/rss2/sample1.xml"))
```


### TODO

- [x] factor out all parse utils into its own module, accessible from extension modules
- [x] record used namespaces
- [x] implement atom namespace
- [x] implement itunes namespace
- [x] implement psc namespace
- [x] implement content (encoded) namespace
- [x] support feeds in atom format
- [ ] introduce some kind of error/warning stack for feed shaming

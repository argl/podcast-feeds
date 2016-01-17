Podcast-Feeds
======

Elixir RSS/Atom parser for Podcast feeds. Built on the [erlsom](https://github.com/willemdj/erlsom) xml parser in SAX mode.
It uses [timex](https://github.com/bitwalker/timex) for parsing dates.

## Setup

Add **podcast-feeds** into your mix dependencies and applications:

```elixir
def application do
  [applications: [:podcast_feeds]]
end

defp deps do
  [{:podcast_feeds, "~> 1.0.0"}]
end
```
Then run ```mix deps.get``` to install podcast-feeds.

## Example

```elixir
{:ok, feed, _rest} = PodcastFeeds.parse_file("./test/fixtures/rss2/sample.xml")
```


### TODO

- [x] factor out all parse utils into its own module, accessible from extension modules
- [x record used namespaces
- [ ] implement itunes namespace
- [ ] introduce some kind of error/warning stack for feed shaming

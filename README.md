Podcast-Feeds
======

Elixir RSS/Atom parser optiomized for Podcast feeds. Built on the erlsom xml parser.
It uses [timex](https://github.com/bitwalker/timex) for parsing dates.

## Setup

Add **podcast-feeds** into your mix dependencies and applications:

```elixir
def application do
  [applications: [:podcast-feeds]]
end

defp deps do
  [{:podcast-feeds, "~> 1.0.0"}]
end
```
Then run ```mix deps.get``` to install podcast-feeds.

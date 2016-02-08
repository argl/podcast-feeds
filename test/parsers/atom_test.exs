defmodule PodcastFeeds.Test.Parsers.Atom do
  use ExUnit.Case, async: false

  alias PodcastFeeds.Parsers.Atom

  @chunk_size 32768

  setup do
    {:ok, [
      sample1: "test/fixtures/atom/sample1.xml"
    ]}
  end

  test "parse_meta", %{sample1: sample1} do
    fstream = File.read!(sample1)

    state = Atom.parse_feed(fstream)
    m = state.feed.meta
    assert m.title == "Podcast Title"
    assert m.link == "http://localhost:8081/"
    assert m.author == "John Doe"
    assert m.last_build_date == %Timex.DateTime{
      calendar: :gregorian, day: 1, hour: 12, minute: 00, month: 1, ms: 0, second: 0, year: 2010,
      timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}
    }
  end

  test "parse_entry", %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = Atom.parse_feed(fstream)
    assert 1 == length(state.feed.entries)
    [e | _rest] = state.feed.entries
    assert e.title == "Item 1 Title"
    assert e.link == "http://localhost:8081/item1"
    assert e.description == "Item 1 Description"
    assert e.publication_date == %Timex.DateTime{
      calendar: :gregorian, day: 2, hour: 12, minute: 00, month: 1, ms: 0, second: 0, year: 2010,
      timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}
    }
  end

end
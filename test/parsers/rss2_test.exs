defmodule PodcastFeeds.Test.Parsers.RSS2 do
  use ExUnit.Case, async: false

  alias PodcastFeeds.Parsers.RSS2

  @chunk_size 32768

  setup do
    {:ok, [
      sample1: "test/fixtures/rss2/sample1.xml"
    ]}
  end

  test "parse_meta", %{sample1: sample1} do
    fstream = File.read!(sample1)

    state = RSS2.parse_feed(fstream)
    m = state.feed.meta
    assert m.title == "Podcast Title"
    assert m.link == "http://localhost:8081/"
    assert m.description == "Podcast Description"
    assert m.author == "author@example.com"
    assert m.language == "en-US"
    assert m.copyright == "Copyright 2002, Example Entity"
    assert m.publication_date == %Timex.DateTime{calendar: :gregorian, day: 13, hour: 0, minute: 0, month: 11, ms: 0, second: 0, timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2015}
    assert m.last_build_date == %Timex.DateTime{calendar: :gregorian, day: 12, hour: 22, minute: 47, month: 11, ms: 0, second: 30, timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2015}
    assert m.generator == "Generator"
    assert m.cloud == %PodcastFeeds.Cloud{domain: "cloud.example.com", path: "/path", port: 80, protocol: "xml-rpc", register_procedure: "cloud.register"}
    assert m.ttl == 60
    assert m.managing_editor == "podcast-editor@example.com (Paula Podcaster)"
    assert m.web_master == "podcast-webmaster@example.com (Wendy Webmaster)"

    assert m.categories == ["channel category 1", "channel category 2"]
    assert m.skip_hours == [1, 2]
    assert m.skip_days == ["Monday", "Tuesday"]
    assert m.image != nil

    i = m.image
    assert i.title == "Podcast Image Title"
    assert i.url == "http://localhost:8081/podcast-image.jpg"
    assert i.link == "http://podcast.example.com/"
    assert i.description == "Image description"
    assert i.width == 200
    assert i.height == 100
  end

  test "parse_entry", %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    assert 2 == length(state.feed.entries)
    [e | _rest] = state.feed.entries
    assert e.title == "Item 1 Title"
    assert e.link == "http://localhost:8081/item1"
    assert e.description == "Item 1 Description"
    assert e.author == "author@example.com"
    assert e.categories == ["item category 1", "item category 2"]
    assert e.comments == "http://example.com/item1/#coments"
    assert e.enclosure == %PodcastFeeds.Enclosure{length: "123456", type: "audio/mp4", url: "http://localhost:8081/item1.m4a"}
    assert e.guid == "guid-item-1"
    assert e.publication_date == %Timex.DateTime{
      calendar: :gregorian, day: 11, hour: 1, minute: 0, month: 11, ms: 0, second: 0, year: 2015,
      timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}
    }
    assert e.source == "http://localhost:8081/example.xml"
  end


  test "parse atom namespace in meta" , %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    m = state.feed.meta
    atom_links = m.atom_links
    assert length(atom_links) == 4
    atom_self = Enum.find(atom_links, 0, fn(link) -> link.rel == "self" end)
    assert atom_self
    assert atom_self.href == "http://localhost:8081/example.xml"

    atom_first = Enum.find(atom_links, 0, fn(link) -> link.rel == "first" end)
    assert atom_first
    assert atom_first.href == "http://localhost:8081/example.xml"
  end

  test "parse atom namespace in entry" , %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    assert 2 == length(state.feed.entries)
    [e | rest] = state.feed.entries

    assert length(e.contributors) == 2
    [contributor | contributors] = e.contributors
    assert contributor.name == "Conrad Contributor"
    assert contributor.uri == "http://contributor.example.com/conrad"
    assert contributor.email == "conrad@contributor.example.com"

    [contributor | _contributors] = contributors
    assert contributor.name == "Caspar Contributor"
    assert contributor.uri == "http://contributor.example.com/caspar"
    assert contributor.email == "caspar@contributor.example.com"

    atom_links = e.atom_links
    assert length(atom_links) == 1
    atom_deep = Enum.find(atom_links, 0, fn(link) -> link.rel == "http://localhost:8081/deep-link" end)
    assert atom_deep
    assert atom_deep.href == "http://localhost:8081/example.xml#"

    [e | _rest] = rest
    contributors = e.contributors
    assert length(contributors) == 1
  end

  test "parse itunes namespace in meta" , %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    i = state.feed.meta.itunes
    assert i.author == "Itunes Author"
    assert i.categories ==  [["Arts", "Design"], ["Society & Culture", "History"], ["Technology", "Gadgets"]]
    assert i.block == false
    assert i.image_href == "http://localhost:8081/podcast-image.jpg"
    assert i.explicit == nil
    assert i.complete == true
    assert i.new_feed_url == "http://new-feed-url.example.com/new-feed"
    assert i.owner != nil
    assert match? %PodcastFeeds.Parsers.Ext.Itunes.Owner{}, i.owner
    assert i.owner.name == "Itunes Owner Name"
    assert i.owner.email == "Itunes Owner Email"
    assert i.subtitle == "Itunes Subtitle"
    assert i.summary == "Itunes Summary"
  end

  test "parse itunes namespace in entry" , %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    assert 2 == length(state.feed.entries)

    [e | rest] = state.feed.entries
    i = e.itunes
    assert i
    assert i.block == true
    assert i.image_href == "http://localhost:8081/item1-image.jpg"
    assert i.duration == "01:00:00"
    assert i.explicit == false
    assert i.is_closed_captioned == true
    assert i.order == 10
    assert i.subtitle == "Item 1 Subtitle"
    assert i.summary == "Item 1 Itunes Summary"

    [e | _] = rest
    i = e.itunes
    assert i
    assert i.block == false
  end


  test "parse psc namespace in entry" , %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    [e | _entries] = state.feed.entries
    chapters = e.chapters
    assert chapters
    assert length(chapters) == 3
    [c | chapters] = chapters
    assert c.start == "00:00:00.000"
    assert c.title == "Item 1 Chapter 1"
    assert c.href == "http://example.com/test-chapter-ref"
    assert c.image == "http://example.com/test-chapter-image.jpeg"

    [c | _chapters] = chapters
    assert c.start == "00:01:00.000"
    assert c.title == "Item 1 Chapter 2"
    assert c.href == nil
    assert c.image == nil
  end

  test "parse content namespace in entry" , %{sample1: sample1} do
    fstream = File.read!(sample1)
    state = RSS2.parse_feed(fstream)
    [e | _entries] = state.feed.entries
    content = e.content_encoded
    assert content
    assert content == "Item 1 Content <em>Encoded</em>"
  end


end
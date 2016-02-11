defmodule PodcastFeeds.Test do
  use ExUnit.Case, async: true

  test "parse basic rss2"  do
    document = File.read!("test/fixtures/rss2/sample1.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  test "parse basic atom"  do  
    document = File.read!("test/fixtures/atom/sample1.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  test "parse cre feed" do
    document = File.read!("test/fixtures/rss2/cre.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  test "parse 99pi feed" do
    document = File.read!("test/fixtures/rss2/99pi.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  test "parse al feed" do
    document = File.read!("test/fixtures/rss2/al.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  test "parse aem feed" do
    document = File.read!("test/fixtures/rss2/aem.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  test "parse rlm feed" do
    document = File.read!("test/fixtures/rss2/rlm.xml")
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

  @tag skip: "prints errors to console but otherwise runs fine"
  test "parse invalid feeds" do
    document = File.read!("test/fixtures/empty-root.xml")
    res = PodcastFeeds.parse(document)
    assert {:error, "Unknown feed format"} = res

    document = File.read!("test/fixtures/no-feed.xml")
    res = PodcastFeeds.parse(document)
    assert {:error, "Unknown feed format"} = res

    document = File.read!("test/fixtures/empty.xml")
    res = PodcastFeeds.parse(document)
    assert {:error, "expected_element_start_tag at line 1 col 1"} = res

    document = File.read!("test/fixtures/non-well-formed.xml")
    res = PodcastFeeds.parse(document)
    assert {:error, "error_scanning_entity_ref at line 4 col 37"} = res

  end

end

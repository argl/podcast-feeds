defmodule PodcastFeeds.Test do
  use ExUnit.Case, async: true

  setup do
    sample1 = "test/fixtures/rss2/sample1.xml"

    {:ok, [
      sample1: sample1, 
    ]}
  end

  test "parse file" , %{sample1: sample1} do
    res = PodcastFeeds.parse_file(sample1)
    assert {:ok, %PodcastFeeds.Feed{} = _feed, _namespaces, _rest} = res
  end

end

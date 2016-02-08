defmodule PodcastFeeds.Test do
  use ExUnit.Case, async: true

  setup do
    sample1 = "test/fixtures/rss2/sample1.xml"
    sample2 = "test/fixtures/atom/sample1.xml"

    {:ok, [
      sample1: sample1, 
      sample2: sample2, 
    ]}
  end

  test "parse" , %{sample1: sample1, sample2: sample2} do
    document = File.read!(sample1)
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  
    document = File.read!(sample2)
    res = PodcastFeeds.parse(document)
    assert {:ok, %PodcastFeeds.Feed{} = _feed} = res
  end

end

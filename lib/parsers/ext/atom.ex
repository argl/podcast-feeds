defmodule PodcastFeeds.Parsers.Ext.Atom do

  @prefix 'atom'

  def sax_event_handler({:startElement, _uri, name, @prefix, _attributes}, state) do
    state
  end
  def sax_event_handler({:endElement, uri, name, @prefix}, state) do
    state
  end

end
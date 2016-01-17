defmodule PodcastFeeds.Parsers.Ext.Atom do

  def sax_event_handler({:startElement, _uri, name, 'atom', _attributes}, state) do
    state
  end
  def sax_event_handler({:endElement, uri, name, 'atom'}, state) do
    state
  end

end
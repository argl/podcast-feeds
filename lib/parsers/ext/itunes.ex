defmodule PodcastFeeds.Parsers.Ext.Itunes do

  alias PodcastFeeds.Parsers.Helpers
  alias PodcastFeeds.Parsers.Helpers.ParserState
  alias PodcastFeeds.Contributor
  alias PodcastFeeds.Entry
  
  @prefix 'itunes'

  # <itunes:author>Metaebene Personal Media - Tim Pritlove</itunes:author>
  # <itunes:summary>Intensive und ausführliche Gespräche über Themen aus Technik, Kultur und Gesellschaft, das ist CRE. Interessante Gesprächspartner stehen Rede und Antwort zu Fragen, die man normalerweise selten gestellt bekommt. CRE möchte  aufklären, weiterbilden und unterhalten.</itunes:summary>
  # <itunes:category text="Technology"/>
  # <itunes:owner>
  #   <itunes:name>Tim Pritlove</itunes:name>
  #   <itunes:email>cre@metaebene.me</itunes:email>
  # </itunes:owner>
  # <itunes:image href="http://cre.fm/wp-content/cache/podlove/f9/f9fa0c2498fe20a0f85d4928e8423e/cre-technik-kultur-gesellschaft_original.jpg"/>
  # <itunes:subtitle>Der Interview-Podcast mit Tim Pritlove</itunes:subtitle>
  # <itunes:keywords/>
  # <itunes:block>no</itunes:block>
  # <itunes:explicit>no</itunes:explicit>



  # XML-Tag               Channel Item  Anzeigeort in iTunes/Hinweise
  # <itunes:author>             J J     Spalte „Interpret“
  # <itunes:block>              J J     verhindert, dass eine Folge oder ein Podcast angezeigt wird
  # <itunes:category>           J       Spalte „Kategorie“ und iTunes Store Übersicht
  # <itunes:image>              J J     selber Ort wie Albumcover
  # <itunes:duration>             J     Spalte „Länge“
  # <itunes:explicit>           J J     Jugendschutz-Grafik in der Spalte „Name“
  # <itunes:isClosedCaptioned>    J     Grafik für einblendbare Untertitel in der Spalte „Name“
  # <itunes:order>                J     Aufheben der Reihenfolge von Folgen im Store
  # <itunes:complete>           J       zeigt die Vollständigkeit von Podcasts an; keine weiteren Folgen
  # <itunes:new-feed-url>       J       nicht sichtbar, wird verwendet, um iTunes über eine neue URL‑Adresse des Feeds zu informieren
  # <itunes:owner>              J       nicht sichtbar, nur für Kontaktaufnahme
  # <itunes:subtitle>           J J     Spalte „Beschreibung“
  # <itunes:summary>            J J     nach Klick auf das „i“ in der Spalte „Beschreibung“

  # <itunes:author>
  # Der Inhalt dieses Tags wird in der Spalte „Interpret“ in iTunes angezeigt. Wenn kein <itunes:author> Tag 
  # vorhanden ist, verwendet iTunes den Inhalt im Tag <author>. Falls das Tag <itunes:author> auf der Ebene 
  # des RSS‑Podcast-Feeds nicht vorhanden ist, verwendet iTunes den Inhalt des Tags <managingEditor>.
  def sax_event_handler({:startElement, _uri, 'author', @prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  def sax_event_handler({:endElement, _uri, 'author', @prefix}, state) do
    state
    |> handle_character_content_for_itunes([PodcastFeeds.Meta, PodcastFeeds.Entry], :author)
  end


  # <itunes:block>
  # Ist in einem <channel> Element (d. h. in einem Podcast-Element) ein <itunes:block> Tag 
  # vorhanden und auf den Wert „yes“ gesetzt, bedeutet dies, dass der gesamte Podcast nicht 
  # im Podcast-Verzeichnis des iTunes Store erscheint.

  # Bei einem <item> Element (d. h. bei einer Folge), dessen <itunes:block> Tag auf den Wert 
  # „yes“ gesetzt ist, wird dadurch verhindert, dass die entsprechende Folge im Podcast-
  # Verzeichnis des iTunes Store erscheint. Es empfiehlt sich, dies zu tun, um nur eine 
  # bestimmte Folge zu blockieren, deren Inhalt dazu führen könnte, dass der gesamte Podcast 
  # aus dem iTunes Store entfernt wird.

  # Ein beliebiger anderer Wert im <itunes:block> Tag hat keinerlei Auswirkung.
  def sax_event_handler({:startElement, _uri, 'block', @prefix, _attributes}, state) do
    %{state | element_acc: ""}
  end
  def sax_event_handler({:endElement, _uri, 'block', @prefix}, state) do
    state
    |> (fn(state) ->
      case state.element_acc do
        "yes" -> state
        _ -> %{state | element_acc: nil}
      end
    end).()
    |> handle_character_content_for_itunes([PodcastFeeds.Meta, PodcastFeeds.Entry], :block)
  end




  # fall through
  def sax_event_handler({:startElement, _uri, _name, @prefix, _attributes}, state) do
    state
  end
  def sax_event_handler({:endElement, _uri, _name, @prefix}, state) do
    state
  end



  # helper
  defp handle_character_content_for_itunes(state, allowed_structs, key) do
    %ParserState{element_stack: [elem | element_stack], element_acc: element_acc} = state    
    case Enum.find(allowed_structs, &(&1 == elem.__struct__)) do
      nil -> state
      _ok ->
        itunes = %{elem.itunes | key => element_acc}
        elem = %{elem | itunes: itunes}
        %{state | element_stack: [elem | element_stack]}
      _ -> state
    end
  end

end
defmodule PodcastFeeds.Test.Parsers.RSS2 do
  use ExUnit.Case, async: true

  alias PodcastFeeds.Parsers.RSS2

  @chunk_size 32768

  setup do
    sample1 = "test/fixtures/rss2/sample1.xml"
    # {:ok, sample2} = File.read("test/fixtures/rss2/sample2.xml")
    # {:ok, sample3} = File.read("test/fixtures/rss2/cre.xml")
    # {:ok, sample4} = File.read("test/fixtures/rss2/wpt.xml")
    # {:ok, big_sample} = File.read("test/fixtures/rss2/bigsample.xml")

    {:ok, [
      sample1: sample1, 
      #sample2: sample2,
      #sample3: sample3,
      #sample4: sample4,
      #big_sample: big_sample
    ]}
  end

  # test "valid?", %{sample1: sample1, sample2: sample2, sample3: sample3, sample4: sample4} do
  #   {:ok, wrong_doc} = File.read("test/fixtures/wrong.xml")

  #   assert RSS2.valid?(sample1) == true
  #   assert RSS2.valid?(sample2) == true
  #   assert RSS2.valid?(sample3) == true
  #   assert RSS2.valid?(sample4) == true
  #   assert RSS2.valid?(wrong_doc) == false
  # end

  test "parse_meta", %{sample1: sample1} do
    fstream = File.stream!(sample1, [], @chunk_size)

    res = RSS2.parse(fstream)
    assert {:ok, feed, rest} = res
    m = feed.meta
    assert m.title == "Podcast Title"
    assert m.link == "http://localhost:8081/"
    assert m.description == "Podcast Description"
    assert m.author == "author@example.com"
    assert m.language == "en-US"
    assert m.copyright == "Copyright 2002, Example Entity"
    assert m.publication_date == %Timex.DateTime{calendar: :gregorian, day: 13, hour: 0, minute: 0, month: 11, ms: 0, second: 0, timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2015}
    assert m.last_build_date == %Timex.DateTime{calendar: :gregorian, day: 12, hour: 22, minute: 47, month: 11, ms: 0, second: 30, timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2015}
    assert m.generator == "Generator"
    assert m.cloud == %{domain: 'cloud.example.com', path: '/path', port: '80', protocol: 'xml-rpc', registerProcedure: 'cloud.register'}
    assert m.ttl == 60
    assert m.managing_editor == "podcast-editor@example.com (Paula Podcaster)"
    assert m.web_master == "podcast-webmaster@example.com (Wendy Webmaster)"

    assert m.categories == ["channel category 2", "channel category 1"]
    assert m.skip_hours == [1, 2]
    assert m.skip_days == ["Monday", "Tuesday"]
    # assert m.image == ""
  end

  # test "parse_meta with atom links", %{sample3: sample3} do
  #   {:ok, feed} = RSS2.parse(sample3)
  #   assert length(feed.meta.atom_links) == 9
  #   [link | rest ] = feed.meta.atom_links
  #   assert link.title =="CRE: Technik, Kultur, Gesellschaft (MPEG-4 AAC Audio)"
  #   assert link.rel == "self"
  #   assert link.href == "http://feeds.metaebene.me/cre/m4a"
  #   [link | _ ] = rest
  #   assert link.title =="CRE: Technik, Kultur, Gesellschaft (MP3 Audio)"
  #   assert link.rel == "alternate"
  #   assert link.href == "http://cre.fm/feed/mp3"
  # end

  # test "parse podast feed meta including itunes namespaced elements", %{sample3: sample3} do
  #   {:ok, feed} = RSS2.parse(sample3)
  #   assert feed.meta == %Feedme.MetaData{
  #     atom_links: [
  #        %Feedme.AtomLink{href: "http://feeds.metaebene.me/cre/m4a", rel: "self",
  #         title: "CRE: Technik, Kultur, Gesellschaft (MPEG-4 AAC Audio)", type: "application/rss+xml"},
  #        %Feedme.AtomLink{href: "http://cre.fm/feed/mp3", rel: "alternate", title: "CRE: Technik, Kultur, Gesellschaft (MP3 Audio)",
  #         type: "application/rss+xml"},
  #        %Feedme.AtomLink{href: "http://cre.fm/feed/oga", rel: "alternate", title: "CRE: Technik, Kultur, Gesellschaft (Ogg Vorbis Audio)",
  #         type: "application/rss+xml"},
  #        %Feedme.AtomLink{href: "http://cre.fm/feed/opus", rel: "alternate", title: "CRE: Technik, Kultur, Gesellschaft (Ogg Opus Audio)",
  #         type: "application/rss+xml"}, %Feedme.AtomLink{href: "http://cre.fm/feed/m4a?paged=2", rel: "next", title: nil, type: nil},
  #        %Feedme.AtomLink{href: "http://cre.fm/feed/m4a", rel: "first", title: nil, type: nil},
  #        %Feedme.AtomLink{href: "http://cre.fm/feed/m4a?paged=4", rel: "last", title: nil, type: nil},
  #        %Feedme.AtomLink{href: "http://metaebene.superfeedr.com", rel: "hub", title: nil, type: nil},
  #        %Feedme.AtomLink{href: "https://flattr.com/submit/auto?user_id=timpritlove&language=de_DE&url=http%3A%2F%2Fcre.fm&title=CRE%3A+Technik%2C+Kultur%2C+Gesellschaft&description=Der+Interview-Podcast+mit+Tim+Pritlove",
  #         rel: "payment", title: "Flattr this!", type: "text/html"}
  #     ], author: nil, category: nil, cloud: nil, copyright: nil,
  #     description: "Der Interview-Podcast mit Tim Pritlove", docs: nil, generator: "Podlove Podcast Publisher v2.3.3",
  #     image: %Feedme.Image{description: nil, height: nil, link: "http://cre.fm", title: "CRE: Technik, Kultur, Gesellschaft",
  #      url: "http://cre.fm/wp-content/cache/podlove/f9/f9fa0c2498fe20a0f85d4928e8423e/cre-technik-kultur-gesellschaft_original.jpg", width: nil},
  #     itunes: %Feedme.Itunes{author: "Metaebene Personal Media - Tim Pritlove", block: false, category: "Technology", complete: false, duration: nil,
  #      explicit: false, image:  "http://cre.fm/wp-content/cache/podlove/f9/f9fa0c2498fe20a0f85d4928e8423e/cre-technik-kultur-gesellschaft_original.jpg", 
  #      is_closed_captioned: false, new_feed_url: nil, order: nil, owner: %{email: "cre@metaebene.me", name: "Tim Pritlove"},
  #      subtitle: "Der Interview-Podcast mit Tim Pritlove",
  #      summary: "Intensive und ausführliche Gespräche über Themen aus Technik, Kultur und Gesellschaft, das ist CRE. Interessante Gesprächspartner stehen Rede und Antwort zu Fragen, die man normalerweise selten gestellt bekommt. CRE möchte  aufklären, weiterbilden und unterhalten."},
  #     language: "de-DE",
  #     last_build_date: %Timex.DateTime{calendar: :gregorian, day: 12, hour: 22, minute: 47, month: 11, ms: 0, second: 30,
  #      timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2015},
  #     link: "http://cre.fm", managing_editor: nil, publication_date: nil, rating: nil, skip_days: [], skip_hours: [],
  #     title: "CRE: Technik, Kultur, Gesellschaft", ttl: nil, web_master: nil
  #   }
  # end

  # test "parse_entry", %{big_sample: big_sample} do
  #   {:ok, feed} = RSS2.parse(big_sample)
  #   entry = hd(feed.entries)

  #   assert entry == %Feedme.Entry{
  #     author: nil,
  #     categories: [ "elixir" ],
  #     comments: nil,
  #     description: "<p>I previously <a href=\"http://blog.drewolson.org/the-value-of-explicitness/\">wrote</a> about explicitness in Elixir. One of my favorite ways the language embraces explicitness is in its distinction between eager and lazy operations on collections. Any time you use the <code>Enum</code> module, you're performing an eager operation. Your collection will be transformed/mapped/enumerated immediately. When you use</p>",
  #     enclosure: nil,
  #     guid: "9b68a5a7-4ab0-420e-8105-0462357fa1f1",
  #     itunes: %Feedme.Itunes{
  #       author: nil, block: nil, category: nil, complete: false, duration: nil, explicit: false, image: nil, is_closed_captioned: false,
  #       new_feed_url: nil, order: nil, owner: nil, subtitle: nil, summary: nil
  #     },
  #     link: "http://blog.drewolson.org/elixir-streams/",
  #     enclosure: %Feedme.Enclosure{
  #       url: "http://www.tutorialspoint.com/mp3s/tutorial.mp3",
  #       length: "12216320",
  #       type: "audio/mpeg"
  #     },
  #     publication_date: %Timex.DateTime{
  #       calendar: :gregorian,
  #       day: 8,
  #       hour: 13,
  #       minute: 43,
  #       month: 6,
  #       ms: 0,
  #       second: 5,
  #       timezone: %Timex.TimezoneInfo{
  #         abbreviation: "UTC",
  #         from: :min,
  #         full_name: "UTC",
  #         offset_std: 0,
  #         offset_utc: 0,
  #         until: :max
  #       },
  #       year: 2015
  #     },
  #     source: nil,
  #     title: "Elixir Streams"
  #   }
  # end

  # test "parse podast feed entries with itunes and podlove simple chapter (psc)", %{sample3: sample3} do
  #   {:ok, feed} = RSS2.parse(sample3)
  #   entries = feed.entries
  #   assert entries
  #   assert length(entries) == 60
  #   entry = hd(entries)
  #   assert entry == %Feedme.Entry{author: nil, categories: [], comments: nil,
  #     description: "Der einst von Linus Torvalds geschaffene Betriebssystemkernel Linux ist eine freie Reimplementierung der UNIX Betriebssystemfamilie und hat sich in den letzten 20 Jahren sehr eigenständig entwickelt. Der Rest des Systems, das Userland, hat sich aber noch sehr stark an der klassischen Struktur von UNIX orientiert. Mit der Initiative systemd hat sich dies geändert und es entsteht eine sehr eigenständige Definition einer Linux-Systemebene, die sich zwischen Kernel und Anwendungen entfaltet und dort die Regeln der Installation und Systemadministration neu definiert.\n\nIch spreche mit dem Initiator des Projekts, Lennart Poettering, der schon vorher verschiedene Subsysteme zur Linux-Landschaft beigetragen hat über die Motivation und Struktur des Projekts, den aktuellen und zukünftigen Möglichkeiten der Software und welche kulturellen Auswirkungen der Einzug einer neuen Abstraktionsebene mit sich bringt.",
  #     enclosure: %Feedme.Enclosure{length: "65230396", type: "audio/mp4",
  #     url: "http://tracking.feedpress.it/link/13440/2008525/cre209-das-linux-system.m4a"}, guid: "podlove-2015-11-09t23:06:21+00:00-4501b131b3a9b1a",
  #     itunes: %Feedme.Itunes{author: "Metaebene Personal Media - Tim Pritlove", block: nil, category: nil, complete: false, duration: "02:50:21",
  #     explicit: false, image: "http://cre.fm/wp-content/cache/podlove/fc/e7582fdeecef74ce069536b0283454/cre209-das-linux-system_original.jpg", is_closed_captioned: false, new_feed_url: nil, order: nil, owner: nil,
  #     subtitle: "systemd leitet die neue Generation der Linux Systemarchitektur ein",
  #     summary: "Der einst von Linus Torvalds geschaffene Betriebssystemkernel Linux ist eine freie Reimplementierung der UNIX Betriebssystemfamilie und hat sich in den letzten 20 Jahren sehr eigenständig entwickelt. Der Rest des Systems, das Userland, hat sich aber noch sehr stark an der klassischen Struktur von UNIX orientiert. Mit der Initiative systemd hat sich dies geändert und es entsteht eine sehr eigenständige Definition einer Linux-Systemebene, die sich zwischen Kernel und Anwendungen entfaltet und dort die Regeln der Installation und Systemadministration neu definiert.\n\nIch spreche mit dem Initiator des Projekts, Lennart Poettering, der schon vorher verschiedene Subsysteme zur Linux-Landschaft beigetragen hat über die Motivation und Struktur des Projekts, den aktuellen und zukünftigen Möglichkeiten der Software und welche kulturellen Auswirkungen der Einzug einer neuen Abstraktionsebene mit sich bringt."},
  #     link: "http://cre.fm/cre209-das-linux-system",
  #     publication_date: %Timex.DateTime{calendar: :gregorian, day: 10, hour: 1, minute: 15, month: 11, ms: 0, second: 50,
  #     timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2015},
  #     source: nil, title: "CRE209 Das Linux System",
  #     psc: [
  #       %Feedme.Psc{href: nil, image: nil, start: "00:00:00.000", title: "Intro"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:01:42.024", title: "Begrüßung"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:03:03.037", title: "Hacken als Grundeinstellung"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:06:09.589", title: "Persönlicher Werdegang"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:17:16.981", title: "PulseAudio"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:30:21.917", title: "Avahi"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:38:24.502", title: "Elitismus und Geheimwissen"},
  #       %Feedme.Psc{href: nil, image: nil, start: "00:51:38.717", title: "systemd : Beweggründe zur Entwicklung"},
  #       %Feedme.Psc{href: nil, image: nil, start: "01:25:27.304", title: "systemd: Vorbilder und alte Zöpfe"},
  #       %Feedme.Psc{href: nil, image: nil, start: "01:48:18.600", title: "systemd Entwickler"},
  #       %Feedme.Psc{href: nil, image: nil, start: "01:50:23.048", title: "UEFI Booting und Secure Boot"},
  #       %Feedme.Psc{href: nil, image: nil, start: "02:04:54.909", title: "Linux System Startup and Shutdown"},
  #       %Feedme.Psc{href: nil, image: nil, start: "02:16:16.477", title: "Der systemd Graph"},
  #       %Feedme.Psc{href: nil, image: nil, start: "02:29:54.685", title: "Network Setup mit systemd"},
  #       %Feedme.Psc{href: nil, image: nil, start: "02:42:10.547", title: "Ausblick und Fazit"}
  #     ],
  #     atom_links: [%Feedme.AtomLink{href: "http://cre.fm/cre209-das-linux-system#", rel: "http://podlove.org/deep-link", title: nil,
  #       type: nil},
  #       %Feedme.AtomLink{href: "https://flattr.com/submit/auto?user_id=timpritlove&language=de_DE&url=http%3A%2F%2Fcre.fm%2Fcre209-das-linux-system&title=CRE209+Das+Linux+System&description=Der+einst+von+Linus+Torvalds+geschaffene+Betriebssystemkernel+Linux+ist+eine+freie+Reimplementierung+der+UNIX+Betriebssystemfamilie+und+hat+sich+in+den+letzten+20+Jahren+sehr+eigenst%C3%A4ndig+entwickelt.+Der+Rest+des+Systems%2C+das+Userland%2C+hat+sich+aber+noch+sehr+stark+an+der+klassischen+Struktur+von+UNIX+orientiert.+Mit+der+Initiative+systemd+hat+sich+dies+ge%C3%A4ndert+und+es+entsteht+eine+sehr+eigenst%C3%A4ndige+Definition+einer+Linux-Systemebene%2C+die+sich+zwischen+Kernel+und+Anwendungen+entfaltet+und+dort+die+Regeln+der+Installation+und+Systemadministration+neu+definiert.%0D%0A%0D%0AIch+spreche+mit+dem+Initiator+des+Projekts%2C+Lennart+Poettering%2C+der+schon+vorher+verschiedene+Subsysteme+zur+Linux-Landschaft+beigetragen+hat+%C3%BCber+die+Motivation+und+Struktur+des+Projekts%2C+den+aktuellen+und+zuk%C3%BCnftigen+M%C3%B6glichkeiten+der+Software+und+welche+kulturellen+Auswirkungen+der+Einzug+einer+neuen+Abstraktionsebene+mit+sich+bringt.",
  #       rel: "payment", title: "Flattr this!", type: "text/html"}
  #     ]
  #   }
  #   assert entry.psc
  #   psc = entry.psc
  #   assert is_list(psc)
  #   assert length(psc) == 15
  # end

  # test "parse_entry with atom links", %{sample3: sample3} do
  #   {:ok, feed} = RSS2.parse(sample3)
  #   entries = feed.entries
  #   assert entries
  #   [entry | _ ] = entries
  #   assert length(entry.atom_links) == 2
  #   [link | links] = entry.atom_links
  #   assert link.title == nil
  #   assert link.rel == "http://podlove.org/deep-link"
  #   assert link.href == "http://cre.fm/cre209-das-linux-system#"
  #   assert link.type == nil
  #   [link | _ ] = links
  #   assert link.title =="Flattr this!"
  #   assert link.rel == "payment"
  #   assert link.href == "https://flattr.com/submit/auto?user_id=timpritlove&language=de_DE&url=http%3A%2F%2Fcre.fm%2Fcre209-das-linux-system&title=CRE209+Das+Linux+System&description=Der+einst+von+Linus+Torvalds+geschaffene+Betriebssystemkernel+Linux+ist+eine+freie+Reimplementierung+der+UNIX+Betriebssystemfamilie+und+hat+sich+in+den+letzten+20+Jahren+sehr+eigenst%C3%A4ndig+entwickelt.+Der+Rest+des+Systems%2C+das+Userland%2C+hat+sich+aber+noch+sehr+stark+an+der+klassischen+Struktur+von+UNIX+orientiert.+Mit+der+Initiative+systemd+hat+sich+dies+ge%C3%A4ndert+und+es+entsteht+eine+sehr+eigenst%C3%A4ndige+Definition+einer+Linux-Systemebene%2C+die+sich+zwischen+Kernel+und+Anwendungen+entfaltet+und+dort+die+Regeln+der+Installation+und+Systemadministration+neu+definiert.%0D%0A%0D%0AIch+spreche+mit+dem+Initiator+des+Projekts%2C+Lennart+Poettering%2C+der+schon+vorher+verschiedene+Subsysteme+zur+Linux-Landschaft+beigetragen+hat+%C3%BCber+die+Motivation+und+Struktur+des+Projekts%2C+den+aktuellen+und+zuk%C3%BCnftigen+M%C3%B6glichkeiten+der+Software+und+welche+kulturellen+Auswirkungen+der+Einzug+einer+neuen+Abstraktionsebene+mit+sich+bringt."
  #   assert link.type == "text/html"
  # end


  # test "parse_entries", %{sample1: sample1, sample2: sample2} do
  #   {:ok, feed} = RSS2.parse(sample1)
  #   [item1, item2] = feed.entries
    
  #   assert item1.title == "RSS Tutorial"
  #   assert item1.link == "http://www.w3schools.com/webservices"
  #   assert item1.description == "New RSS tutorial on W3Schools"

  #   assert item2.title == "XML Tutorial"
  #   assert item2.link == "http://www.w3schools.com/xml"
  #   assert item2.description == "New XML tutorial on W3Schools"

  #   {:ok, feed} = RSS2.parse(sample2)
  #   [item1, item2] = feed.entries
    
  #   assert item1.title == nil
  #   assert item1.link == "http://www.w3schools.com/webservices"
  #   assert item1.description == nil

  #   assert item2.title == nil
  #   assert item2.link == "http://www.w3schools.com/xml"
  #   assert item2.description == nil
  # end

  # test "parse wpt", %{sample4: sample4} do
  #   {:ok, feed} = RSS2.parse(sample4)
  #   assert feed.meta.title == "WordPress Weekly"
  #   entries = feed.entries
  #   assert 12 == length(entries)
  #   assert Enum.at(entries, 0).guid == "http://wptavern.com?p=49295&preview_id=49295"
  # end


  # test "parse sample1", %{sample1: sample1} do
  #   {:ok, feed} = RSS2.parse(sample1)

  #   assert feed == %Feedme.Feed{
  #     entries: [
  #       %Feedme.Entry{author: nil, categories: [], psc: [], comments: nil, description: "New RSS tutorial on W3Schools",
  #         enclosure: nil, guid: nil, itunes: %Feedme.Itunes{
  #           author: nil, block: nil, category: nil, complete: false, duration: nil, explicit: false, image: nil, is_closed_captioned: false,
  #           new_feed_url: nil, order: nil, owner: nil, subtitle: nil, summary: nil
  #         }, link: "http://www.w3schools.com/webservices", publication_date: nil, source: nil, title: "RSS Tutorial"
  #       },
  #       %Feedme.Entry{author: nil, categories: [], psc: [], comments: nil, description: "New XML tutorial on W3Schools", 
  #         enclosure: nil, guid: nil, itunes: %Feedme.Itunes{
  #           author: nil, block: nil, category: nil, complete: false, duration: nil, explicit: false, image: nil, is_closed_captioned: false,
  #           new_feed_url: nil, order: nil, owner: nil, subtitle: nil, summary: nil
  #         }, link: "http://www.w3schools.com/xml", publication_date: nil, source: nil, title: "XML Tutorial"
  #       }
  #     ],
  #     meta: %Feedme.MetaData{
  #       description: "Free web building tutorials",
  #       link: "http://www.w3schools.com", 
  #       title: "W3Schools Home Page",
  #       skip_days: ["Monday", "Tuesday"],
  #       skip_hours: [1,2],
  #       image: %Feedme.Image{
  #         title: "Test Image",
  #         description: "test image...",
  #         url: "http://localhost/image"
  #       },
  #       last_build_date: %Timex.DateTime{
  #         calendar: :gregorian, day: 16,
  #         hour: 9, minute: 54, month: 8, ms: 0, second: 5,
  #         timezone: %Timex.TimezoneInfo{
  #           abbreviation: "UTC", from: :min,
  #           full_name: "UTC",
  #           offset_std: 0,
  #           offset_utc: 0,
  #           until: :max},
  #         year: 2015},
  #       publication_date: %Timex.DateTime{
  #         calendar: :gregorian,
  #         day: 15,
  #         hour: 9, minute: 54, month: 8, ms: 0, second: 5,
  #         timezone: %Timex.TimezoneInfo{
  #           abbreviation: "UTC",
  #           from: :min,
  #           full_name: "UTC",
  #           offset_std: 0,
  #           offset_utc: 0,
  #           until: :max
  #         },
  #         year: 2015
  #       },
  #       itunes: %Feedme.Itunes{
  #         author: nil, block: nil, category: nil, complete: false, duration: nil, explicit: false,
  #         image: nil, is_closed_captioned: false, new_feed_url: nil, order: nil, owner: nil, subtitle: nil, summary: nil
  #       }
  #     }
  #   }
  # end
end

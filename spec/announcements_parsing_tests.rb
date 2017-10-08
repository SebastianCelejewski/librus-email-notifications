module LibrusEmailNotifications
	class AnnouncementsParsingTests < MiniTest::Test

		def setup
			announcements_parser = AnnouncementsParser.new(nil, nil, nil)
			announcements_html_page = Nokogiri::HTML(open("./spec/announcements.html"))
			@announcements = announcements_parser.load_current_announcements(announcements_html_page)
		end

		def test_Should_extract_sender
			assert_equal "Ewa Ławicka", @announcements[0].sender
		end

		def test_Should_extract_date
			assert_equal "2017-10-04", @announcements[1].date
		end

		def test_Should_extract_subject
			assert_equal "Jak zachować i rozwijać więź z nastolatkiem - Warsztaty dla rodziców organizowane przez MOPR", @announcements[2].subject
		end

		def test_Should_extract_text
			assert_equal "Pierwszy test piszemy w piątek (6.10.2017 r.). Godzinę i nr sali podają poloniści uczący w danej klasie.", @announcements[6].text
		end
	end
end
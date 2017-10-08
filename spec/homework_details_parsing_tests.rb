module LibrusEmailNotifications
	class HomeworkDetailsParsingTests < MiniTest::Test

		def setup
			homework_parser = HomeworkParser.new(nil, nil, nil)
			homework_details_html_page = Nokogiri::HTML(open("./spec/homework_details.html"))
			@homework_details = homework_parser.load_homework_details(homework_details_html_page)
		end

		def test_Should_detect_valid_number_of_homework
			assert_equal "Uczniowie mają przynieść zgromadzone rekwizyty do Muzeum Osobliwości Pana Kleksa.", @homework_details
		end

	end
end
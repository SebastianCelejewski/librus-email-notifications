module LibrusEmailNotifications
	class HomeworkParsingTests < MiniTest::Test

		def setup
			homework_parser = HomeworkParser.new(nil, nil, nil)
			homework_html_page = Nokogiri::HTML(open("./spec/homework.html"))
			@homework = homework_parser.load_current_homework(homework_html_page)
		end

		def test_Should_detect_valid_number_of_homework
			assert_equal 1, @homework.length
		end

		def test_Should_extract_id
			assert_equal "60208", @homework[0].id
		end

		def test_Should_extract_subject
			assert_equal "Język polski", @homework[0].subject
		end

		def test_Should_extract_teacher
			assert_equal "Milena Labuda", @homework[0].teacher
		end

		def test_Should_extract_topic
			assert_equal "Akademia Pana Kleksa", @homework[0].topic
		end

		def test_Should_extract_category
			assert_equal "brak", @homework[0].category
		end

		def test_Should_extract_start_date
			assert_equal "2017-10-02", @homework[0].start_date
		end

		def test_Should_extract_end_date
			assert_equal "2017-10-11", @homework[0].end_date
		end

		def test_Should_extract_status
			assert_equal "-", @homework[0].status
		end
	end
end
module LibrusEmailNotifications
	class GradesParsingTests < MiniTest::Test

		def setup
			grades_parser = GradesParser.new(nil, nil, nil)
			grades_html_page = Nokogiri::HTML(open("./spec/grades.html"))
			@grades = grades_parser.load_current_grades(grades_html_page)
		end

		def test_Should_ignore_hidden_rows_with_no_values
			assert_equal 11, @grades.length
		end
	end
end
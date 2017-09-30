module LibrusEmailNotifications

    class GradesParser

        def initialize(data_dir, smtp_sender, logger, throttle = false)
            @data_dir = data_dir
            @smtp_sender = smtp_sender
            @logger = logger
            @df = "%Y-%m-%d %H:%M:%S"
            @throttle = throttle
        end

        def process(librus_user)
            @logger.log "Starting grades processing"

            data_file = "#{@data_dir}/#{librus_user}-data.txt"

            if !File.exists?(data_file)
                File.open(data_file,"w"){}
            end

            Capybara.page.find(:xpath, "//a[@id='icon-oceny']").trigger("click")

            if @throttle
                @logger.log "Waiting 2 seconds"
                sleep 2
            end

            grades_html_page = Nokogiri::HTML(Capybara.page.html)

            current_grades = load_current_grades grades_html_page
            previous_grades = load_previous_grades librus_user
            new_grades = find_new_grades previous_grades, current_grades

            @logger.log "Number of previous grades: #{previous_grades.length}"
            @logger.log "Number of current grades: #{current_grades.length}"
            @logger.log "Number of new grades: #{new_grades.length}"

            if new_grades.length > 0
                sender_display_name = "Librus (#{librus_user})"
                topic = "Nowe oceny: "

                topic += new_grades.map{ |o| "#{o.value} (#{o.category})"}.join(", ")

                text = ""
                new_grades.each do |grade|
                    text += "<b>Ocena</b>: #{grade.value}<br/>"
                    text += "<b>Kategoria</b>: #{grade.category}<br/>"
                    text += "<b>Data</b>: #{grade.date}<br/>"
                    text += "<b>Nauczyciel</b>: #{grade.teacher}<br/>"
                    text += "<b>Waga</b>: #{grade.weight}<br/>"
                    text += "<br/>"
                end

                smtp_start_time = DateTime.now

                begin
                    @smtp_sender.send_message(sender_display_name, topic, text)
                    save_new_grades librus_user, current_grades
                    smtp_status = :success
                rescue Exception => e
                    puts "[SmtpSender] Failed to send email-message: #{e}"
                    @logger.log e.backtrace
                    smtp_status = :failure
                end

                smtp_end_time = DateTime.now
                smtp_duration = ((smtp_end_time-smtp_start_time).to_f*86400).to_i

                File.open("log/smtp.log","a") {|f| f.puts "#{smtp_start_time.strftime(@df)};#{smtp_end_time.strftime(@df)};#{smtp_duration};#{smtp_status}" }

            end
                
            @logger.log "Grades processing complete"
        end

        def load_current_grades(grades_html_page)
            rows = grades_html_page.xpath("//tr[@class='line1 detail-grades']")
 
            grades = Array.new

            rows.each do |row|
                value = row.at_xpath('td[1]').text()
                category = row.at_xpath('td[3]').text()
                date = row.at_xpath('td[4]').text()
                teacher = row.at_xpath('td[5]').text()
                weight = row.at_xpath('td[7]').text()

                next if date == ""

                grade = Grade.new value, category, date, teacher, weight
                grades << grade
            end

            return grades
        end

        def load_previous_grades(librus_user)
            file_name = "#{@data_dir}/#{librus_user}.grades"
            if File.exists?(file_name)
                grades = JSON.load(File.read(file_name)).map{|h| Grade.from_hash h}
                return grades
            else
                File.open(file_name, "w") {|f| f.puts "[]"}
                return Array.new
            end
        end

        def save_new_grades(librus_user, grades)
            file_name = "#{@data_dir}/#{librus_user}.grades"
            File.open(file_name, "w") { |f| f.write(JSON.generate(grades))}
        end

        def find_new_grades(previous_grades, current_grades)
            new_grades = current_grades.clone
            previous_grades.each do |grade|
                grade_idx = new_grades.index(grade)
                if grade_idx != nil
                    new_grades.delete_at(grade_idx)
                end
            end

            return new_grades
        end
    end
end

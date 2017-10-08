module LibrusEmailNotifications

    class HomeworkParser

        def initialize(data_dir, smtp_sender, logger, throttle = false)
            @data_dir = data_dir
            @smtp_sender = smtp_sender
            @logger = logger
            @df = "%Y-%m-%d %H:%M:%S"
            @throttle = throttle
        end

        def process(librus_user)
            @logger.log "Starting homework processing"

            Capybara.page.find(:xpath, "//a[@id='icon-zadania']").trigger("click")
            
            if @throttle
                @logger.log "Waiting 2 seconds"
                sleep 2
            end

            homework_html_page = Nokogiri::HTML(Capybara.page.html)

            current_homework = load_current_homework homework_html_page
            previous_homework = load_previous_homework librus_user
            new_homework = find_new_homework(previous_homework, current_homework)

            @logger.log "Number of previous homework: #{previous_homework.length}"
            @logger.log "Number of current homework: #{current_homework.length}"
            @logger.log "Number of new homework: #{new_homework.length}"

            if new_homework.length > 0
                new_homework.each do |homework|
                    sender_display_name = "#{homework.teacher} (#{librus_user})"
                    topic = "Zadanie domowe: #{homework.topic} (#{homework.subject}, zadane: #{homework.start_date}, termin: #{homework.end_date})"
                    text = "Przedmiot: #{homework.subject}<br/>"
                    text += "Nauczyciel: #{homework.teacher}<br/>"
                    text += "Temat: #{homework.topic}<br/>"
                    text += "Data zadania: #{homework.start_date}<br/>"
                    text += "Termin wykonania: #{homework.end_date}<br/>"
                    text += "<br/>"

                    smtp_start_time = DateTime.now

                    begin
                        @smtp_sender.send_message(sender_display_name, topic, text)
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

                save_new_homework librus_user, current_homework
            end
                
            @logger.log "Homework processing complete"
        end

        def load_current_homework(homework_html_page)
            rows = homework_html_page.xpath("//tr[@class='line1']")
            homework = Array.new
            rows.each do |row|
                subject = row.at_xpath("td[1]").text().strip()
                teacher = row.at_xpath("td[2]").text().strip()
                topic = row.at_xpath("td[3]").text().strip()
                category = row.at_xpath("td[4]").text().strip()
                start_date = row.at_xpath("td[5]").text().strip()
                end_date = row.at_xpath("td[7]").text().strip()
                status = row.at_xpath("td[9]").text().strip()
                homework << Homework.new(subject, teacher, topic, category, start_date, end_date, status)
            end            
            return homework
        end

        def load_previous_homework(librus_user)
            file_name = "#{@data_dir}/#{librus_user}.homework"
            if File.exists?(file_name)
                homework = JSON.load(File.read(file_name)).map{|h| Homework.from_hash h}
                return homework
            else
                File.open(file_name, "w") {|f| f.puts "[]"}
                return Array.new
            end
        end

        def save_new_homework(librus_user, homework)
            file_name = "#{@data_dir}/#{librus_user}.homework"
            File.open(file_name, "w") { |f| f.write(JSON.generate(homework))}
        end

        def find_new_homework(previous_homework, current_homework)
            new_homework = current_homework.clone
            previous_homework.each do |homework|
                homework_idx = new_homework.index(homework)
                if homework_idx != nil
                    new_homework.delete_at(homework_idx)
                end
            end

            return new_homework
        end
    end
end

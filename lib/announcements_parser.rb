module LibrusEmailNotifications

    class AnnouncementsParser

        def initialize(data_dir, smtp_sender, logger)
            @data_dir = data_dir
            @smtp_sender = smtp_sender
            @logger = logger
            @df = "%Y-%m-%d %H:%M:%S"
        end

        def process(librus_user)
            @logger.log "Starting announcements processing"

            Capybara.page.find(:xpath, "//a[@id='icon-ogloszenia']").click
            announcements_html_page = Nokogiri::HTML(Capybara.page.html)

            current_announcements = load_current_announcements announcements_html_page
            previous_announcements = load_previous_announcements librus_user
            new_announcements = find_new_announcements previous_announcements, current_announcements

            @logger.log "Number of previous announcements: #{previous_announcements.length}"
            @logger.log "Number of current announcements: #{current_announcements.length}"
            @logger.log "Number of new announcements: #{new_announcements.length}"

            if new_announcements.length > 0
                new_announcements.each do |announcement|
                    sender_display_name = "#{announcement.sender} (#{librus_user})"
                    topic = "Ogłoszenie: " + announcement.subject
                    text = announcement.text

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

                save_new_announcements librus_user, current_announcements
            end
                
            @logger.log "Announcements processing complete"
        end

        def load_current_announcements(announcements_html_page)
            rows = announcements_html_page.xpath("//table[@class='decorated form big center printable']")
            announcements = Array.new
            rows.each do |row|
                sender = row.at_xpath("tbody/tr[1]/td").text()
                date = row.at_xpath("tbody/tr[2]/td").text()
                subject = row.at_xpath("thead/tr/td").text()
                text = row.at_xpath("tbody/tr[3]/td").inner_html()

                puts "#{sender}, #{date}, #{subject}, #{text[0..100]}"

                announcements << Announcement.new(sender, date, subject, text)
            end            
            return announcements
        end

        def load_previous_announcements(librus_user)
            file_name = "data/#{librus_user}.announcements"
            if File.exists?(file_name)
                announcements = JSON.load(File.read(file_name)).map{|h| Announcement.from_hash h}
                return announcements
            else
                File.open(file_name, "w") {|f| f.puts "[]"}
                return Array.new
            end
        end

        def save_new_announcements(librus_user, announcements)
            file_name = "data/#{librus_user}.announcements"
            File.open(file_name, "w") { |f| f.write(JSON.generate(announcements))}
        end

        def find_new_announcements(previous_announcements, current_announcements)
            new_announcements = current_announcements.clone
            previous_announcements.each do |announcement|
                announcement_idx = new_announcements.index(announcement)
                if announcement_idx != nil
                    new_announcements.delete_at(announcement_idx)
                end
            end

            return new_announcements
        end
    end
end
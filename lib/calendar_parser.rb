module LibrusEmailNotifications

    class CalendarParser

        def initialize(data_dir, smtp_sender, logger)
            @data_dir = data_dir
            @smtp_sender = smtp_sender
            @logger = logger
            @df = "%Y-%m-%d %H:%M:%S"
        end

        def process(librus_user)
            @logger.log "Starting calendar processing"

            Capybara.page.find(:xpath, "//a[@id='icon-terminarz']").trigger("click")
            sleep 2
            events_html_page = Nokogiri::HTML(Capybara.page.html)

            current_events = load_current_events events_html_page
            previous_events = load_previous_events librus_user
            new_events = find_new_events previous_events, current_events

            @logger.log "Number of previous events: #{previous_events.length}"
            @logger.log "Number of current events: #{current_events.length}"
            @logger.log "Number of new events: #{new_events.length}"

            if new_events.length > 0
                new_events.each do |event|
                    sender_display_name = "Librus (#{librus_user})"
                    topic = "Ogłoszenie: " + event.title
                    text = event.text

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

                save_new_events librus_user, current_events
            end
                
            @logger.log "Calendar processing complete"
        end

        def load_current_events(events_html_page)
            result = Array.new

            month = "%02d" % events_html_page.xpath("//select[@name='miesiac']/option[@selected]/@value").text.to_i
            month_name = events_html_page.xpath("//select[@name='miesiac']/option[@selected]").text
            year = events_html_page.xpath("//select[@name='rok']/option[@selected]/@value").text

            days = events_html_page.xpath("//div[@class='kalendarz-dzien']")

            days.each do |day|
                day_number = day.at_xpath("div[@class='kalendarz-numer-dnia']").text().to_i
                day_number_dd = "%02d" % day_number
                events = day.xpath("table/tbody/tr/td")
                events.each do |event|
                    info = event.inner_html
                    title = "#{year}-#{month}-#{day_number_dd}: #{info.gsub(/<br\/?>/,' ')}"
                    hover = event[:title]
                    date = "Data: #{day_number} #{month_name} #{year}"
                    text = [date, info, hover].join("<br/>")
                    date = "#{year}-#{month}-#{day_number}"

                    result << Event.new(date, title, text)
                end
            end
            return result
        end

        def load_previous_events(librus_user)
            file_name = "data/#{librus_user}.events"
            if File.exists?(file_name)
                events = JSON.load(File.read(file_name)).map{|h| Event.from_hash h}
                return events
            else
                File.open(file_name, "w") {|f| f.puts "[]"}
                return Array.new
            end
        end

        def save_new_events(librus_user, events)
            file_name = "data/#{librus_user}.events"
            File.open(file_name, "w") { |f| f.write(JSON.generate(events))}
        end

        def find_new_events(previous_events, current_events)
            new_events = current_events.clone
            previous_events.each do |event|
                event_idx = new_events.index(event)
                if event_idx != nil
                    new_events.delete_at(event_idx)
                end
            end

            return new_events
        end
    end
end

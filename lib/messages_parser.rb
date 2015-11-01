module LibrusEmailNotifications
    class MessagesParser
        
        def initialize data_dir, smtp_sender, logger
            @data_dir = data_dir
            @smtp_sender = smtp_sender
            @logger = logger
            @df = "%Y-%m-%d %H:%M:%S"
        end

        def process librus_user
            @logger.log "Starting messages processing"

            data_file = "#{@data_dir}/#{librus_user}-data.txt"

            if !File.exists?(data_file)
                File.open(data_file,"w"){}
            end

            Capybara.page.find(:xpath, "//a[@id='icon-wiadomosci']").click

            @logger.log "Scanning links"
            links = Capybara.page.all(:xpath, "//a[starts-with(@href, '/wiadomosci/')]")
            hrefs = links.map{|x| x[:href]}.select{ |x| /.*\/wiadomosci\/\d+\/\d+\/(.*)/.match(x) != nil}

            ids = hrefs.map{|href| /.*\/wiadomosci\/\d+\/\d+\/(.*)/.match(href)[1].to_i}.uniq.sort

            @logger.log "Found #{ids.length} links"

            sent_messages_ids = File.read(data_file).split(/\n/).map{|x| x.to_i}

            messages_that_need_to_be_processed = ids - sent_messages_ids

            @logger.log "#{messages_that_need_to_be_processed.length} of them have to be processed"

            messages_that_need_to_be_processed.each do |id|

                @logger.log "Processing message #{id}"

                link_ending = "/wiadomosci/1/5/#{id}"
                link = Capybara.page.find(:xpath, "//a[starts-with(@href, '#{link_ending}')]")
                link.click

                sender = Capybara.page.find(:xpath,"//tr[td[1]/b[text()='Nadawca']]/td[2]").text()
                topic = Capybara.page.find(:xpath,"//tr[td[1]/b[text()='Temat']]/td[2]").text()
                date = Capybara.page.find(:xpath,"//tr[td[1]/b[text()='Wysłano']]/td[2]").text()

                full_page_html = Nokogiri::HTML(Capybara.page.html)
                text = full_page_html.xpath("//div[@class='container-message-content']").inner_html

                sender_name = sender.split(/\(/)[0]
                sender_display_name = "#{sender_name} (#{librus_user})"

                smtp_start_time = DateTime.now

                begin
                    @smtp_sender.send_message(sender_display_name, topic, text)
                    File.open(data_file,"a") {|f| f.puts id}
                    smtp_status = :success
                rescue Exception => e
                    puts "[SmtpSender] Failed to send email-message: #{e}"
                    @logger.log e.backtrace
                    smtp_status = :failure
                end

                smtp_end_time = DateTime.now
                smtp_duration = ((smtp_end_time-smtp_start_time).to_f*86400).to_i

                File.open("log/smtp.log","a") {|f| f.puts "#{smtp_start_time.strftime(@df)};#{smtp_end_time.strftime(@df)};#{smtp_duration};#{smtp_status}" }

                @logger.log "Coming back to messages list"

                link = Capybara.page.find(:xpath, "//a[starts-with(@href, '/wiadomosci/5')]")
                link.click
            end

            @logger.log "Messages processing complete"

        end
    end
end

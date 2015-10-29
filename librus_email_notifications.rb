require 'capybara'
require 'capybara/poltergeist'
require './smtp_sender'
require 'nokogiri'
require 'date'

module LibrusEmailNotifications

    data_dir = "data"
    log_dir = "log"

    if ARGV.length != 6
            puts "Usage: ruby librus.rb <librus_user> <librus_password> <smtp_host> <smtp_email> <smtp_user> <smtp_password>"
            abort
    end

    librus_user = ARGV[0]
    librus_password = ARGV[1]

    smtp_host = ARGV[2]
    smtp_email = ARGV[3]
    smtp_user = ARGV[4]
    smtp_password = ARGV[5]

    data_file = "#{data_dir}/#{librus_user}-data.txt"

    Dir.mkdir(data_dir) unless File.exists?(data_dir)
    Dir.mkdir(log_dir) unless File.exists?(log_dir)

    if !File.exists?(data_file)
        File.open(data_file,"w"){}
    end

    smtp_sender = SmtpSender.new(smtp_host, smtp_email, smtp_user, smtp_password)

    Capybara.register_driver :poltergeist_errorless do |app|
      Drivers::Poltergeist.new(app, js_errors: false, timeout: 10000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any'])
    end

    Capybara.default_driver = :poltergeist

    puts "Browsing to the login page"

    Capybara.page.visit('http://synergia.librus.pl/loguj')

    puts "Logging into Librus"

    Capybara.page.fill_in('login', :with => librus_user)
    Capybara.page.fill_in('passwd', :with => librus_password)
    Capybara.page.find(:xpath, "//input[@name='loguj']").click

    puts "Waiting 10 seconds"

    sleep 10

    puts "Navigating to messages"

    Capybara.page.find(:xpath, "//a[@id='icon-wiadomosci']").click

    puts "Scanning links"
    links = Capybara.page.all(:xpath, "//a[starts-with(@href, '/wiadomosci/')]")
    hrefs = links.map{|x| x[:href]}.select{ |x| /.*\/wiadomosci\/\d+\/\d+\/(.*)/.match(x) != nil}

    ids = hrefs.map{|href| /.*\/wiadomosci\/\d+\/\d+\/(.*)/.match(href)[1].to_i}.uniq.sort

    puts "Found #{ids.length} links"

    sent_messages_ids = File.read(data_file).split(/\n/).map{|x| x.to_i}

    messages_that_need_to_be_processed = ids - sent_messages_ids

    puts "#{messages_that_need_to_be_processed.length} of them have to be processed"

    messages_that_need_to_be_processed.each do |id|

            puts "Processing message #{id}"

            link_ending = "/wiadomosci/1/5/#{id}"
            link = Capybara.page.find(:xpath, "//a[starts-with(@href, '#{link_ending}')]")
            link.click

            sender = Capybara.page.find(:xpath,"//tr[td[1]/b[text()='Nadawca']]/td[2]").text()
            topic = Capybara.page.find(:xpath,"//tr[td[1]/b[text()='Temat']]/td[2]").text()
            date = Capybara.page.find(:xpath,"//tr[td[1]/b[text()='Wysłano']]/td[2]").text()

            full_page_html = Nokogiri::HTML(Capybara.page.html)
            text = full_page_html.xpath("//div[@class='container-message-content']").inner_html

            sender_name = sender.split(/\(/)[0]

            smtp_start_time = DateTime.now

            smtp_sender.send_message(sender_display_name, "Sebastian.Celejewski@wp.pl", topic, text)

            smtp_end_time = DateTime.now

            File.open(data_file,"a") {|f| f.puts id}

            smtp_duration = ((smtp_end_time-smtp_start_time).to_f*86400).to_i

            puts "smtp start time: #{smtp_start_time}"
            puts "smtp end time: #{smtp_end_time}"
            puts "smtp end time: #{smtp_end_time}"
            puts "smtp duration: #{smtp_duration}"

            File.open("log/smtp.log","a") {|f| f.puts "#{smtp_duration}" }

            puts "Coming back to messages list"

            link = Capybara.page.find(:xpath, "//a[starts-with(@href, '/wiadomosci/5')]")
            link.click
    end

    puts "Done."
end
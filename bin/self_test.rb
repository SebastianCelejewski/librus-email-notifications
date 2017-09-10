require './lib/librus_email_notifications'

module LibrusEmailNotifications

    data_dir = "self_test_data"
    log_dir = "self_test_log"

    Dir.mkdir(data_dir) unless File.exists?(data_dir)
    Dir.mkdir(log_dir) unless File.exists?(log_dir)

    logger = Logger.new log_dir

    if ARGV.length != 2
        logger.log "Usage: ruby librus.rb <librus_user> <librus_password>"
        abort
    end

    librus_user = ARGV[0]
    librus_password = ARGV[1]

    logger.log "Librus Email Notifications initialization for account #{librus_user}"

    smtp_sender = SelfTestSmtpSender.new
    messages_parser = MessagesParser.new data_dir, smtp_sender, logger
    grades_parser = GradesParser.new data_dir, smtp_sender, logger
    announcements_parser = AnnouncementsParser.new data_dir, smtp_sender, logger
    calendar_parser = CalendarParser.new data_dir, smtp_sender, logger

    Capybara.register_driver :poltergeist_errorless do |app|
      Drivers::Poltergeist.new(app, js_errors: false, timeout: 10000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any'])
    end

    Capybara.default_driver = :poltergeist

    logger.log "Browsing to the login page"

    Capybara.page.visit('http://synergia.librus.pl/loguj')
    current_url = Capybara.page.current_url
    logger.log "Current url is #{current_url}"

    logger.log "Logging into Librus"

    Capybara.page.fill_in('login', :with => librus_user)
    Capybara.page.fill_in('passwd', :with => librus_password)
    Capybara.page.find(:xpath, "//input[@name='loguj']").click

#    messages_parser.process librus_user
#    grades_parser.process librus_user
#    announcements_parser.process librus_user
#    calendar_parser.process librus_user

    logger.log "Librus Email Notifications processing complete for account #{librus_user}"

end
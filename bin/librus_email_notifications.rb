﻿require './lib/librus_email_notifications'

module LibrusEmailNotifications

    data_dir = "data"
    log_dir = "log"

    Dir.mkdir(data_dir) unless File.exists?(data_dir)
    Dir.mkdir(log_dir) unless File.exists?(log_dir)

    logger = Logger.new log_dir

    if ARGV.length != 7
        logger.log "Usage: ruby librus.rb <librus_user> <librus_password> <smtp_host> <smtp_email> <smtp_user> <smtp_password> <recipient_email_addressess>"
        abort
    end

    librus_user = ARGV[0]
    librus_password = ARGV[1]

    smtp_host = ARGV[2]
    smtp_email = ARGV[3]
    smtp_user = ARGV[4]
    smtp_password = ARGV[5]

    recipients = ARGV[6]

    logger.log "Librus Email Notifications initialization for account #{librus_user}"

    smtp_sender = SmtpSender.new(smtp_host, smtp_email, smtp_user, smtp_password, recipients)
    messages_parser = MessagesParser.new data_dir, smtp_sender, logger
    grades_parser = GradesParser.new data_dir, smtp_sender, logger

    if File.exists?("lockfile")
        logger.log "Another instance is already running. Aborting."
        abort
    end

    at_exit do
        File.delete("lockfile")
    end

    File.open("lockfile","w") {}

    Capybara.register_driver :poltergeist_errorless do |app|
      Drivers::Poltergeist.new(app, js_errors: false, timeout: 10000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any'])
    end

    Capybara.default_driver = :poltergeist

    logger.log "Browsing to the login page"

    Capybara.page.visit('http://synergia.librus.pl/loguj')

    logger.log "Logging into Librus"

    Capybara.page.fill_in('login', :with => librus_user)
    Capybara.page.fill_in('passwd', :with => librus_password)
    Capybara.page.find(:xpath, "//input[@name='loguj']").click

    logger.log "Waiting 10 seconds"

    sleep 10

    messages_parser.process librus_user
    grades_parser.process librus_user

    logger.log "Librus Email Notifications processing complete for account #{librus_user}"

end
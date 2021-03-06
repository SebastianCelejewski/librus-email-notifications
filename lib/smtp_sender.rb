require 'net/smtp'

module LibrusEmailNotifications

    class SmtpSender

        def initialize(smtp_address, smtp_email, smtp_user, smtp_password, recipients)
            @smtp_email = smtp_email
            @smtp_address = smtp_address
            @smtp_user = smtp_user
            @smtp_password = smtp_password
            @recipients = recipients.split(/,/)

            puts "[SmtpSender] Initialization. SMTP host: #{@smtp_address}, SMTP email:#{@smtp_email}, SMTP user:#{@smtp_user}"
        end

        def send_message(sender_display_name, subject, message)
            smtp = Net::SMTP.new @smtp_address, 25
            smtp.open_timeout = 500
            smtp.read_timeout = 500
            @recipients.each do |recipient|
                puts "[SmtpSender] Sending message to #{recipient} as #{sender_display_name}"

                from = "#{sender_display_name} <#{@smtp_email}>"

                mime_message = "Content-type: text/html; charset=UTF-8\n"
                mime_message += "From: #{from}\n"
                mime_message += "To: #{recipient}\n"
                mime_message += "Subject: #{subject}\n"
                mime_message += "Date: #{DateTime.now.rfc2822}\n"
                mime_message += "X-LEN: 1.0.0\n"
                mime_message += "\n"
                mime_message += message

                smtp.start(@smtp_address, @smtp_user, @smtp_password, :login) do |smtp|
                    smtp.send_message mime_message, @smtp_email, recipient
                end

                puts "[SmtpSender] Message successfully sent to #{recipient}."

                puts "Waiting five seconds"
                sleep 5
            end
        end
    end
end

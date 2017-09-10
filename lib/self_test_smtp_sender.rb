module LibrusEmailNotifications

    class SelfTestSmtpSender

        def send_message(sender_display_name, subject, message)
            puts "[SmtpSender] Email message with subject '#{subject}' would be sent to #{sender_display_name}"
        end
    end
end

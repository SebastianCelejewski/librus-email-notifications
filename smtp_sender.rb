require 'net/smtp'

module LibrusEmailNotifications

        class SmtpSender

                def initialize(smtp_address, smtp_email, smtp_user, smtp_password)
                        @smtp_email = smtp_email
                        @smtp_address = smtp_address
                        @smtp_user = smtp_user
                        @smtp_password = smtp_password

                        puts "[SmtpSender] Email:#{@smtp_email} user:#{@smtp_user} host:#{@smtp_address}"
                end

                def send_message(sender_display_name, recipients, subject, message)
                        puts "[SmtpSender] Sending email messages to #{recipients}"
                        smtp = Net::SMTP.new @smtp_address, 25
                        smtp.open_timeout = 500
                        smtp.read_timeout = 500
                        recipients.split(/;/).each do |recipient|
                                begin
                                        puts "[SmtpSender] Sending message to #{recipient} as #{sender_display_name}"

                                        from = "#{sender_display_name} <#{@smtp_email}>"
                                        puts "From: #{from}"

                                        mime_message = "Content-type: text/html; charset=UTF-8\n"
                                        mime_message += "From: #{from}\n"
                                        mime_message += "To: #{recipient}\n"
                                        mime_message += "Subject: #{subject}\n"
                                        mime_message += "\n"
                                        mime_message += message

                                        smtp.start(@smtp_address, @smtp_user, @smtp_password, :login) do |smtp|
                                                smtp.send_message mime_message, @smtp_email, recipient
                                        end

                                        puts "[SmtpSender] Message successfully sent to #{recipient}."
                                rescue Exception => e
                                        puts "[SmtpSender] Failed to send message to #{recipient}: #{e}"
                                end
                        end
                end
        end
end
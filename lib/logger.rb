module LibrusEmailNotifications
    class Logger

        def initialize(log_dir)
            @log_dir = log_dir
        end

        def log(message)
            log_entry = "#{DateTime.now.strftime("%Y-%m-%d %H:%M:%S")} #{Process.pid} #{message}"
            puts log_entry
            File.open("#{@log_dir}/len.log","a") { |f| f.puts(log_entry) }
        end
    end
end
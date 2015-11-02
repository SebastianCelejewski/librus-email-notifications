module LibrusEmailNotifications
    class Announcement

        attr_reader :sender
        attr_reader :date
        attr_reader :subject
        attr_reader :text

        def initialize sender, date, subject, text
            @sender = sender
            @date = date
            @subject = subject
            @text = text
        end

        def to_json x
            {'sender' => @sender, 'date' => @date, 'subject' => @subject, 'text' => @text}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['sender'], data['date'], data['subject'], data['text']
        end

        def self.from_hash data
            self.new data['sender'], data['date'], data['subject'], data['text']
        end

        def ==(other)
            return sender == other.sender && date == other.date && subject = other.subject && text == other.text
        end        
    end
end
module LibrusEmailNotifications
	class Event
        attr_reader :date
        attr_reader :type
        attr_reader :title
        attr_reader :text

        def initialize date, type, title, text
            @date = date
            @type = type
            @title = title
            @text = text
        end

        def to_json x
            {'date' => @date, 'title' => @title, 'text' => @text}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['date'], data['type'], data['title'], data['text']
        end

        def self.from_hash data
            self.new data['date'], data['type'], data['title'], data['text']
        end

        def ==(other)
            return date == other.date && title == other.title && text == other.text
        end
	end
end

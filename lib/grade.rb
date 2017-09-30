module LibrusEmailNotifications
	class Grade
        attr_reader :subject
        attr_reader :value
        attr_reader :category
        attr_reader :date
        attr_reader :teacher
        attr_reader :weight

        def initialize subject, value, category, date, teacher, weight
            @subject = subject
            @value = value
            @category = category
            @date = date
            @teacher = teacher
            @weight = weight
        end

        def to_json x
            {'subject' => @subject, 'value' => @value, 'category' => @category, 'date' => @date, 'teacher' => @teacher, 'weight' => @weight}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['subject'], data['value'], data['category'], data['date'], data['teacher'], data['weight']
        end

        def self.from_hash data
            self.new data['subject'], data['value'], data['category'], data['date'], data['teacher'], data['weight']
        end

        def ==(other)
            return subject == other.subject && value == other.value && category == other.category && date == other.date
        end
	end
end
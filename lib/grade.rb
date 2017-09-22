module LibrusEmailNotifications
	class Grade
        attr_reader :value
        attr_reader :category
        attr_reader :date
        attr_reader :teacher
        attr_reader :weight

        def initialize value, category, date, teacher, weight
            @value = value
            @category = category
            @date = date
            @teacher = teacher
            @weight = weight
        end

        def to_json x
            {'value' => @value, 'category' => @category, 'date' => @date, 'teacher' => @teacher, 'weight' => @weight}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['value'], data['category'], data['date'], data['teacher'], data['weight']
        end

        def self.from_hash data
            self.new data['value'], data['category'], data['date'], data['teacher'], data['weight']
        end

        def ==(other)
            return value == other.value && category == other.category && date == other.date
        end
	end
end
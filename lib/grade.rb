module LibrusEmailNotifications
	class Grade

        attr_reader :value
        attr_reader :area
        attr_reader :skill
        attr_reader :date
        attr_reader :teacher
        attr_reader :comment

        def initialize value, area, skill, date, teacher, comment
            @value = value
            @area = area
            @skill = skill
            @date = date
            @teacher = teacher
            @comment = comment
        end

        def to_json x
            {'value' => @value, 'area' => @area, 'skill' => @skill, 'date' => @date, 'teacher' => @teacher, 'comment' => @comment}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['value'], data['area'], data['skill'], data['date'], data['teacher'], data['comment']
        end

        def self.from_hash data
            self.new data['value'], data['area'], data['skill'], data['date'], data['teacher'], data['comment']
        end

        def ==(other)
            return value == other.value && area == other.area && skill == other.skill && date == other.date
        end
	end
end
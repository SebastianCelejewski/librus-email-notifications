module LibrusEmailNotifications
	class Homework
		attr_reader :subject
		attr_reader :teacher
		attr_reader :topic
		attr_reader :category
		attr_reader :start_date
		attr_reader :end_date
		attr_reader :status

		def initialize(subject, teacher, topic, category, start_date, end_date, status)
			@subject = subject
			@teacher = teacher
			@topic = topic
			@category = category
			@start_date = start_date
			@end_date = end_date
			@status = status
		end

     	def to_json x
            {'subject' => @subject, 'teacher' => @teacher, 'topic' => @topic, 'category' => @category, 'start_date' => @start_date, 'end_date' => @end_date, 'status' => @status}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['subject'], data['teacher'], data['topic'], data['category'], data['start_date'], data['end_date'], data['status']
        end

        def self.from_hash data
            self.new data['subject'], data['teacher'], data['topic'], data['category'], data['start_date'], data['end_date'], data['status']
        end

        def ==(other)
            return subject == other.subject && teacher == other.teacher && topic == other.topic && start_date == other.start_date && end_date == other.end_date
        end        
	end
end